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

manifest_name=""
oldcommitlog=""
components={}
dictionary={}

projdir_basepath = "/scratch/ckalluri/DAILY/"
release_details_basepath = "/scratch/ckalluri/scripts/yocto-scripts/daily-builds/ssw_branches/"
scriptsdir = "/scratch/ckalluri/scripts/yocto-scripts/"

projdir=projdir_basepath+sys.argv[1]
release_details=release_details_basepath+sys.argv[2]

setupsdkpath = projdir+'/setupsdk'
freshproject = scriptsdir+"freshproject.sh"


#load all components and user config from a file
def update_ssw_branches():
	os.chdir(release_details_basepath)
	os.system("git remote update")
	os.system("git reset --hard origin/master")


#create components data structure
def set_up_component_data_str():
	global components, manifest_name, oldcommitlog

	with open(release_details) as f:
		file_components=json.load(f)
	manifest_name= file_components['yocto_int_manifest']
	oldcommitlog = file_components['commitlog']
	#setup components DS from file_components keeping only relevant info
	for ssw_component in file_components['ssw_components']:
		temp_dict={"branch":ssw_component['release_branch'],"base_url":ssw_component['url']}
		components[ssw_component['component']]=temp_dict
	del components['libmali-xlnx']
	del components['xrt']
	del components['pmu-firmware']
	del components['system-controller-app']
	print("manifest_name=%s\n oldcommitlog=%s\n components=%s\n\n"%(manifest_name, oldcommitlog, components))


#make new project
def create_new_project():
	print('Making New Project...\n')
	shutil.rmtree(projdir)
	os.mkdir(projdir)

#source build script
def clone_new_repo():
	os.chdir(projdir)
	print("Cloning %s manifest"%manifest_name)
	cmd="source {0} {1}".format(freshproject,manifest_name)
	os.system(cmd)
	cmd="source {0}".format(setupsdkpath)
	os.system(cmd)

#find the old commit id from /proj/yocto
def parse_old_commitlog():
	global components
	print('Parse old commits...\n')
	with open(oldcommitlog) as f:
		data=json.load(f)
	for component in components:
		components[component]['old_commit']=data[component]["commit_id"]

#Web scrape for commits
def web_scrape_for_new_commits():
	print('Web Scraping...\n')
	global components, dictionary
	for pkg in components:
		components[pkg]['url']=components[pkg]['base_url']+"/commits/"+components[pkg]['branch']	
		pkg_scrape=urllib.request.urlopen(components[pkg]['url']).read().decode()
		pattern=compile(r"data-url=\"/"+components[pkg]['base_url'].split("gitenterprise.xilinx.com/")[1]+"/commit/(.*)\/_render_node/commits")
		pkg_scrapped_commits=findall(pattern,pkg_scrape)
		components[pkg]['new_commit']=pkg_scrapped_commits[0]
		if components[pkg]['old_commit'] not in pkg_scrapped_commits:
			print("old commit for %s is not visible in provided branch. Check branch %s and old commits %s"%(pkg,components[pkg]['branch'],components[pkg]['old_commit']))
		dictionary[pkg]=(components[pkg]['old_commit'],components[pkg]['new_commit'])
	
#get rid of entries that dont have new commit ids
def finalise_enteries_with_new_commits():
	global dictionary
	for key,value in list(dictionary.items()):
		if value[0]==value[1]:
			del dictionary[key]
	if 'fsbl' in dictionary.keys():
		dictionary['embeddedsw']=dictionary['fsbl']
		del dictionary['fsbl']

#use flag to stop script before build if old commit id not found (to manually fix commit id before builds)
#TBD:handle case when commit in recipe is different from commit in build and different from the HEAD in remote repo
def update_yocto_recipes_branches():
	fix = ''
	for key, value in dictionary.items():
	    flag = 0
	    print("For key %s, value =%s"%(key,value))
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
				    pkg="fsbl" if "embeddedsw" in pkg else [key for key in components.keys() if key==pkg][0] 
				    #Check for commit id info and update it:
				    if value[0] not in filedata:
				          if "gstreamer1.0-omx"==pkg: srcrev_pattern = compile(r"SRCREV_gst-omx = \"(.*)\"")
				          elif "gstreamer1.0"==pkg: srcrev_pattern = compile(r"SRCREV_gstreamer-xlnx = \"(.*)\"")
				          elif ("gstreamer1.0-plugins-base"==pkg or "gstreamer1.0-plugins-good"==pkg or "gstreamer1.0-plugins-bad"==pkg): srcrev_pattern = compile(r"SRCREV_base = \"(.*)\"")
				          else: srcrev_pattern = compile(r"SRCREV = \"(.*)\"")
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
				    branch_data=findall(branch_pattern,filedata)[0] if findall(branch_pattern,filedata) else ""
				    if branch_data and components[pkg]['branch'] != branch_data:
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

def build_with_new_commits():	
	print('Running builds...\n')
	os.chdir(projdir)
	cmd="source {0} >& /dev/null".format(setupsdkpath)
	os.system(cmd)
	data='INHERIT+="rm_work"'
	filename=projdir+'/build/conf/local.conf'

	with open(filename,'a') as f:
		f.write(data + "\n")
		f.write('IMAGE_INSTALL_remove=" tcf-agent"')
		f.write('SSTATE_MIRRORS ?= "file://.* file:///proj/yocto/daily-sstatecache_2021/aarch64/PATH"')
	
	cmd="source {0} >& /dev/null; MACHINE=zcu102-zynqmp bitbake petalinux-image-minimal | tee zcu102.txt; MACHINE=zc702-zynq7 bitbake petalinux-image-minimal | tee zc702output.txt; MACHINE=vck190-versal bitbake petalinux-image-minimal | tee vck190.txt;".format(setupsdkpath)
	os.system(cmd)
	print('\nBuild Done!\n')

def generate_new_commit_changes():
	parse_old_commitlog()
	web_scrape_for_new_commits()
	finalise_enteries_with_new_commits()
	print(dictionary)
	update_yocto_recipes_branches()


#update_ssw_branches()
set_up_component_data_str()
#create_new_project()
#clone_new_repo()
generate_new_commit_changes()
#build_with_new_commits()
