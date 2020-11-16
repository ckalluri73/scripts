#!/bin/bash -x


#Clone the repo based on which the new manifest/branch is to be created
MANIFEST_BRANCH=$1
REPO_BRANCH=$1
REPO_PATH=$2
REPO_DIR=$3
XML_FILE=default.xml

NEW_BRANCH=$4
LAYERS=("core" "meta-clang" "meta-mingw" "meta-petalinux" "meta-vitis-ai" "meta-jupyter" "meta-openamp" "meta-qt5" "meta-xilinx" "meta-browser" "meta-linaro" "meta-openembedded" "meta-virtualization" "meta-xilinx-tools" "meta-xilinx-internal")

Help(){

	echo " Syntax: create_new_manifest.sh $MANIFEST_BRANCH $REPO_PATH $REPO_DIR $NEW_BRANCH" 
	echo " Example: ./create_new_manifest.sh 2020 /scratch/ckalluri/2020 2020.3 rel-v2020.3"
	echo " MANIFEST_BRANCH: branch name of the yocto-manifest.git to clone"
	echo " REPO_PATH: path where the script can fetch all git repos"
	echo " REPO_DIR: directory to clone the yocto layers within REPO_PATH"
	echo " NEW_BRANCH: new manifest/yocto branches to create and push "
}

clone_repo(){
	mkdir -p $REPO_PATH
	cd $REPO_PATH
	mkdir $REPO_DIR
	cd $REPO_DIR

	/usr/bin/curl -k https://storage.googleapis.com/git-repo-downloads/repo > repo
	chmod a+x repo
	./repo init -u https://gitenterprise.xilinx.com/Yocto/yocto-manifests.git -b $MANIFEST_BRANCH -m $XML_FILE
	./repo sync -j 20
	./repo start $REPO_BRANCH --all
}

push_repo_branches(){
	cd ${REPO_PATH}/${REPO_DIR}
	cd sources
	for layer in ${LAYERS[@]}; do 
		echo "${layer}"
		cd ${layer}
		if [ ${layer} == "core" ]; then
			BRANCH_EXISTS=$(git ls-remote --heads https://gitenterprise.xilinx.com/Yocto/poky.git ${NEW_BRANCH})
		else
			BRANCH_EXISTS=$(git ls-remote --heads https://gitenterprise.xilinx.com/Yocto/${layer}.git ${NEW_BRANCH})
		fi
		if [ -n "$BRANCH_EXISTS" ]; then
			echo "${NEW_BRANCH} EXISTS FOR ${layer}"
		else
			echo "CREATING ${NEW_BRANCH} FOR ${layer} "
			git push xilinx ${REPO_BRANCH}:${NEW_BRANCH}
		fi
		cd ../
	done
}

create_yocto_script_branch(){
#Create Yocto-script branch for the same release
	cd ${REPO_PATH}
	rm -rf yocto-scripts
	git clone https://gitenterprise.xilinx.com/Yocto/yocto-scripts.git
	cd yocto-scripts
	git checkout -b ${REPO_BRANCH} remotes/origin/${REPO_BRANCH}
	git push origin ${REPO_BRANCH}:${NEW_BRANCH}
}

create_yocto_manifest(){
	cd ${REPO_PATH}
	rm -rf yocto-manifests
	git clone https://gitenterprise.xilinx.com/Yocto/yocto-manifests.git
	cd yocto-manifests
	git checkout -b ${REPO_BRANCH} remotes/origin/${REPO_BRANCH}
	git checkout -b ${NEW_BRANCH}
	sed -i "s/${REPO_BRANCH}/${NEW_BRANCH}/g" default.xml	
	git add .
	git commit -s -m "default.xml: Create ${NEW_BRANCH} manifest file"
	git push origin ${NEW_BRANCH}:${NEW_BRANCH}
}

Help
clone_repo
push_repo_branches

BRANCH_EXISTS=$(git ls-remote --heads https://gitenterprise.xilinx.com/Yocto/yocto-scripts.git ${NEW_BRANCH})
if [ -z "$BRANCH_EXISTS" ]; then
	echo "${NEW_BRANCH} doesnt exist for yocto-scripts; CREATING NEW ONE!"
	create_yocto_script_branch
fi

BRANCH_EXISTS=$(git ls-remote --heads https://gitenterprise.xilinx.com/Yocto/yocto-manifests.git ${NEW_BRANCH})
if [ -z "$BRANCH_EXISTS" ]; then
	echo "${NEW_BRANCH} doesnt exist for yocto-manifests; CREATING NEW ONE!"
	create_yocto_manifest
fi

