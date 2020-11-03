# create a list of all python recipes in the layer
import glob
import os
import requests
from bs4 import BeautifulSoup
import re
import sys

basepath = "/workspaces/ckalluri/yocto/jupyter_upgrade"
recipepath = os.path.join(basepath,"sources/meta-jupyter/recipes-python")
buildpath = os.path.join(basepath,'builds-upgrade')

#Parse the recipes in the layer
os.chdir(recipepath)
pypipackages = {}
for name in glob.glob('*.bb'):
	if 'python3-' in name:
		oldrecipename=name
		recipename=name.split('_')[0].split('python3-')[1]
		pypipackages[recipename] = {}
		pypipackages[recipename]['curr_ver'] = name.split('_')[1].split('.bb')[0]
		pypipackages[recipename]['new_ver']=None
		pypipackages[recipename]['old_recipename']= name.split('_')[0]
		pypipackages[recipename]['new_recipename']=None

#Go to pypi website and find the latest package version
base_url="https://pypi.org/search/?q="
url_qeury=""

for pkg in pypipackages:
	#print("scrapping pkg = %s"%pkg)
	url_qeury=pkg
	page=requests.get(base_url+url_qeury)
	soup = BeautifulSoup(page.content, 'html.parser')
	results = soup.find_all('h3', class_='package-snippet__title')
	if not results:
		print("Check with URL for package %s"%pkg)
		sys.exit()
	for r in results:
		r=r.text.replace('\n\n','\n').split('\n')
		if r[1].lower()==pkg:
			pypipackages[pkg]['new_ver'] = r[2] 
	#print("pkg:%s %s\n"%(pkg,pypipackages[pkg]))

print("Web scrapping success!")
print("All recipe and pkg version details")
#print pkg details
for keys,values in pypipackages.items():
	print("%s %s\n"%(keys,values))	

#Update recipes to new package versions
for pkg in pypipackages.keys():
	if pypipackages[pkg].get('new_ver') and pypipackages[pkg].get('curr_ver')!=pypipackages[pkg].get('new_ver'):
		pypipackages[pkg]['new_recipename']=pypipackages[pkg]['old_recipename']+'_'+pypipackages[pkg]['new_ver']+'.bb'		
		os.rename(pypipackages[pkg]['old_recipename']+'_'+pypipackages[pkg]['curr_ver']+'.bb',pypipackages[pkg]['new_recipename'])
	else:
		print("No new version found for pkg: %s"%pkg)


