#!/bin/sh

MACHINES=("zcu102-zynqmp" "zynqmp-generic" "zynq-generic" "versal-generic" "vck190-versal" "vck5000-versal" "zc702-zynq7")

bitbake_soc_variants()
{
	MACHINE=${MACHINE} bitbake petalinux-image-minimal | tee ${MACHINE}_${SOC}_minimal.log	
	MACHINE=${MACHINE} bitbake petalinux-image-full | tee ${MACHINE}_${SOC}_full.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything | tee ${MACHINE}_${SOC}_everything.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything -c populate_sdk_ext | tee ${MACHINE}_${SOC}_populate_sdk_ext.log
}

bitbake_non_soc_variants()
{
    	MACHINE=${MACHINE} bitbake petalinux-image-minimal | tee ${MACHINE}_minimal.log	
	MACHINE=${MACHINE} bitbake petalinux-image-full | tee ${MACHINE}_full.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything | tee ${MACHINE}_everything.log
	MACHINE=${MACHINE} bitbake petalinux-image-everything -c populate_sdk_ext | tee ${MACHINE}_populate_sdk_ext.log
}

for MACHINE in ${MACHINES[@]}; do
	source ./setupsdk builds-${MACHINE}
	bitbake_non_soc_variants
	cd ../
done

SOC_VARIANTS_ZYNQMP=("dr" "ev")
#by default SOC_VARIANT for versal is prime 
SOC_VARIANTS_VERSAL=("-ai-core")

for MACHINE in ${MACHINES[@]}; do 
	if [[ $MACHINE == *"zynqmp"* ]]; then
		SOC_VARIANTS=${SOC_VARIANTS_ZYNQMP}
	else 
		SOC_VARIANTS=${SOC_VARIANTS_VERSAL}
	fi
	source ./setupsdk builds-${MACHINE}
	for SOC in ${SOC_VARIANTS}; do
		export SOC_VARIANT=${SOC}
		export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE SOC_VARIANT"       	
		bitbake_soc_variants
	done	
	cd ../
    done
}


