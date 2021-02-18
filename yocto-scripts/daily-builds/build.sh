#!/bin/sh -x

REPO=$1

MACHINES=("zcu102-zynqmp" "vck190-versal" "zc702-zynq" "ultra96-zynqmp")
GENERIC_MACHINES=("zynqmp-generic" "zynq-generic" "versal-generic")
#by default SOC_VARIANT for zynqmp is cg
SOC_VARIANTS_ZYNQMP=("dr" "ev")
#by default SOC_VARIANT for versal is prime 
SOC_VARIANTS_VERSAL=("-ai-core")

BUILDPATH="/workspaces/ckalluri/yocto/${REPO}"
SCRIPTSPATH="/scratch/ckalluri/scripts/yocto-scripts/"

clean_buildpath()
{
    rm -rf ${BUILDPATH}	
    mkdir -p ${BUILDPATH}

}


clone_fresh_repo()
{
   cd ${BUILDPATH}
   ${SCRIPTSPATH}/freshproject.sh ${REPO}

}

bitbake_generic_machines()
{
	MACHINE=${MACHINE} bitbake petalinux-image-minimal | tee ${MACHINE}_${SOC}_minimal.log	
	MACHINE=${MACHINE} bitbake petalinux-image-full | tee ${MACHINE}_${SOC}_full.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything | tee ${MACHINE}_${SOC}_everything.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything -c populate_sdk_ext | tee ${MACHINE}_${SOC}_populate_sdk_ext.log
}

bitbake_non_generic_machines()
{
    	MACHINE=${MACHINE} bitbake petalinux-image-minimal | tee ${MACHINE}_minimal.log	
	MACHINE=${MACHINE} bitbake petalinux-image-full | tee ${MACHINE}_full.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything | tee ${MACHINE}_everything.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything -c populate_sdk_ext | tee ${MACHINE}_populate_sdk_ext.log
}

build_non_generic_machines()
{
    cd ${BUILDPATH}
    source ${BUILDPATH}/setupsdk

    for MACHINE in ${MACHINES[@]}; do 
	bitbake_non_generic_machines
    done
}

build_generic_machines()
{
    cd ${BUILDPATH}
    source ${BUILDPATH}/setupsdk builds-generic
    ln -s ${BUILDPATH}/build/sstate-cache sstate-cache
    ln -s ${BUILDPATH}/build/downloads downloads

    for MACHINE in ${GENERIC_MACHINES[@]}; do 
	if [[ $MACHINE == "zynqmp-generic" ]]; then
		SOC_VARIANTS=${SOC_VARIANTS_ZYNQMP}
	else 
		SOC_VARIANTS=${SOC_VARIANTS_VERSAL}
	fi
	for SOC in ${SOC_VARIANTS}; do
		export SOC_VARIANT=${SOC}
		export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE SOC_VARIANT"       	
		bitbake_generic_machines
	done	
    done
}

add_xilinx_remotes()
{
	LAYERS=("core" "meta-clang" "meta-mingw" "meta-petalinux" "meta-vitis-ai" "meta-jupyter" "meta-openamp" "meta-qt5" "meta-xilinx" "meta-browser" "meta-linaro" "meta-openembedded" "meta-virtualization" "meta-xilinx-tools" "meta-xilinx-internal" "meta-som" "meta-security")

	cd ${BUILDPATH}/sources
	for layer in ${LAYERS[@]}; do
		cd ${layer}
		if [[ ${layer} == "core" ]]; then
			${layer}="poky"
		fi
		git remote add xilinx git://gitenterprise.xilinx.com/Yocto/${layer}.git
		git remote update
	done
}

#clean_buildpath
#clone_fresh_repo
#add_xilinx_remotes
build_non_generic_machines
build_generic_machines
#build_without_internal_layer
#build_with_internal_layer
#build_poky_distro
#run_downloads
