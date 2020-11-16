#!/bin/bash

MANIFEST_BRANCH=$1
REPO_BRANCH=$1
XML_FILE=default.xml

/usr/bin/curl -k https://storage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
./repo init -u https://gitenterprise.xilinx.com/Yocto/yocto-manifests.git -b $MANIFEST_BRANCH -m $XML_FILE
./repo sync -j 20
./repo start $REPO_BRANCH --all
