import os
import shutil
import sys
import time
import urllib.request         #Module for reading from the web
from re import findall
from re import search
from re import compile
import json
from pprint import pprint

#load all components and user config from a file
release_details = sys.argv[1]

with open(release_details) as f:
	components=json.load(f)

#set up paths
projdir = components["release-info"]["projdir"]
manifest_name= components["release-info"]["manifest"]
oldcommitlog = components["release-info"]["oldcommitlog"]
scriptsdir = components["release-info"]["scripts_dir"]

setupsdkpath = projdir+'/setupsdk'
freshproject = scriptsdir+"freshproject.sh"

dictionary={}

#make new project
print('Making New Project...\n')
shutil.rmtree(projdir)
os.mkdir(projdir)
os.chdir(projdir)

#source build script
cmd="source {0} {1}".format(freshproject,manifest_name)
os.system(cmd)
cmd="source {0}".format(setupsdkpath)
os.system(cmd)

#find the old commit id from /proj/yocto
with open(oldcommitlog) as f:
	data=json.load(f)
	components['linux-xlnx']['old_commit']=data["linux-xlnx"]["commit_id"]
	components['uboot-xlnx']['old_commit']=data["u-boot-xlnx"]["commit_id"]
	components['arm-trusted-firmware']['old_commit']=data["arm-trusted-firmware"]["commit_id"]
	components['fsbl']['old_commit']=data["fsbl"]["commit_id"]
	components['device-tree']['old_commit']=data["device-tree"]["commit_id"]
	components['qemu-xilinx']['old_commit']=data["qemu-xilinx"]["commit_id"]
	components['qemu-devicetrees']['old_commit']=data["qemu-devicetrees"]["commit_id"]
	components['xen']['old_commit']=data["xen"]["commit_id"]
	components['kernel-module-hdmi']['old_commit']=data["kernel-module-hdmi"]["commit_id"]
	components['kernel-module-vcu']['old_commit']=data["kernel-module-vcu"]["commit_id"]
	components['libmetal']['old_commit']=data["libmetal"]["commit_id"]
	components['libomxil-xlnx']['old_commit']=data["libomxil-xlnx"]["commit_id"]
	components['libvcu-xlnx']['old_commit']=data["libvcu-xlnx"]["commit_id"]
	components['open-amp']['old_commit']=data["open-amp"]["commit_id"]
	components['vcu-firmware']['old_commit']=data["vcu-firmware"]["commit_id"]
	
#print(components)
print('Web Scraping...\n')
for pkg in components:
	if pkg == "release-info":
		continue
	components[pkg]['url']=components[pkg]['base_url']+"/commits/"+components[pkg]['branch']	
	print("pkg = %s url=%s"%(pkg,components[pkg]['url']))
	pkg_scrape=urllib.request.urlopen(components[pkg]['url']).read().decode()
	pattern=compile(r"data-url=\"/"+components[pkg]['base_url'].split("gitenterprise.xilinx.com/")[1]+"/commit/(.*)\/_render_node/commits")
	pkg_scrapped_commits=findall(pattern,pkg_scrape)
	components[pkg]['new_commit']=pkg_scrapped_commits[0]
	if components[pkg]['old_commit'] not in pkg_scrapped_commits:
		print("old commit for %s is not visible in provided branch. Check branch %s and old commits %s"%(pkg,components[pkg]['branch'],components[pkg]['old_commit']))
	dictionary[pkg]=(components[pkg]['old_commit'],components[pkg]['new_commit'])

#print(components)
print('\n \n')
#print(dictionary)

#get rid of entries that dont have new commit ids
for key,value in list(dictionary.items()):
	if value[0]==value[1]:
		del dictionary[key]
if 'fsbl' in dictionary.keys():
	dictionary['embeddedsw']=dictionary['fsbl']
	del dictionary['fsbl']

#print(dictionary)
#use flag to stop script before build if old commit id not found (to manually fix commit id before builds)
#TBD:handle case when commit in recipe is different from commit in build and different from the HEAD in remote repo
fix = ''
for key, value in dictionary.items():
    flag = 0
    print("\nFor key %s, value =%s \n "%(key,value))
    for root, dirs, filenames in os.walk(projdir+'/sources/meta-xilinx-internal'):
	    for f in filenames:
                    #Based on Key get the file name
		    recipename=os.path.splitext(f)[0]
		    if '_' in recipename:
		            recipename=recipename.split("_")[0]
		    if recipename in key:
			    #Get recipe name to update the commit and branch details
			    fullpath = os.path.join(root, f)
			    filename=f
			    flag = 1
			    f = open(fullpath,'r')
			    filedata = f.read()
			    f.close()
			    #Check if the file uses include file to update commits and if so skip this file
			    filelines=filedata.split("\n")
			    linecount=0
			    newdata=""
			    for i in filelines:
			          if i:
			              linecount+=1 
			    if linecount == 1:
			        continue
			    #Get component name based on the recipe name
			    pkg=filename.split("_")[0] if "_" in filename else filename.split(".")[0]
			    pkg="fsbl" if "embeddedsw" in pkg else [key for key in components.keys() if key in pkg][0] 
			    #Check for commit id info and update it:
			    if value[0] not in filedata:
			          srcrev_pattern = compile(r"SRCREV = \"(.*)\"")
			          srcrev_data=findall(srcrev_pattern,filedata)[0]
			          print(key,":CommitID %s used in builds is not same as commitID in recipe %s \n"%(value[0],srcrev_data))
			          if srcrev_data == value[1]:
			                 print(key,":Recipe is already pointing to latest commit\n")
			          else:
			                 print(key," Update commitId in file:", f, "\nold commit was:", srcrev_data, "\nNew commit is:" ,value[1], '\n')
			                 newdata = filedata.replace(srcrev_data,value[1])
			    else:
			          newdata = filedata.replace(value[0], value[1])
		            #check for branch info:
			    branch_pattern = compile(r"BRANCH = \"(.*)\"")
			    branch_data=findall(branch_pattern,filedata)[0]
			    if components[pkg]['branch'] != branch_data:
			          print(key," Update branch in file:", f, "\nold branch was:", branch_data, "\nNew Branch is:" ,components[pkg]['branch'], '\n')
			          newdata=newdata.replace(branch_data,components[pkg]['branch'])
		            #write to file
			    if newdata:
			          with open(fullpath,'w') as f:
			                f.write(newdata)
    if flag==0:
	    fix = fix + key + ', '

if fix != '':
	print('There has been a change in ' + fix + ' since last succesful build. Building for now with the changed commitids')

print('Running builds...\n')
cmd="source {0} >& /dev/null".format(setupsdkpath)
os.system(cmd)
data='INHERIT+="rm_work"'

filename=projdir+'/build/conf/local.conf'

with open(filename,'a') as f:
	f.write(data + "\n")
	f.write('IMAGE_INSTALL_remove=" tcf-agent"')
	f.write('SSTATE_MIRRORS ?= "file://.* file:///proj/yocto/daily-sstatecache_2021/aarch64/PATH"')

cmd="source {0} >& /dev/null; MACHINE=zcu102-zynqmp bitbake petalinux-image-minimal | tee zcu102.txt; MACHINE=zc702-zynq7 bitbake petalinux-image-minimal | tee zc702output.txt; MACHINE=vck190-versal bitbake petalinux-image-minimal | tee vck190.txt;".format(setupsdkpath)
#os.system(cmd)
print('\nAll Done!\n')

