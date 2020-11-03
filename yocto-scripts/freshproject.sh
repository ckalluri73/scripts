#!/bin/bash

MANIFEST_BRANCH=$1
REPO_BRANCH=rel-$1
XML_FILE=default.xml

/usr/bin/curl -k https://storage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
./repo init -u git://gitenterprise/Yocto/yocto-manifests.git -b $MANIFEST_BRANCH -m $XML_FILE
#./repo init -u git://gitenterprise.xilinx.com/jaewon/yocto-manifests-zynq3.git -b master -m $XML_FILE
./repo sync -j 20
./repo start $REPO_BRANCH --all
