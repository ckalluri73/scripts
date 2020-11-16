TEMPPATH="/scratch/ckalluri/temp"

mkdir -p ${TEMPPATH}
cd ${TEMPPATH}

RELYEAR="2020.2"
BSPPATH="/proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/"
echo ${BSPPATH}

BSPS=("zc702" "zc706" "zcu102" "zcu104" "zcu106" "zcu111" "zcu1275" "zcu1285" "ultra96-reva" "v350-DC01" "vmk180" "zc1751-dc1" "vck190" "vck190-SC" "vc-p-a2197-00-reva-x-prc-01-reva" "vc-p-a2197-00-sc" "kc705")

XSAPATH="project-spec/hw-description/system.xsa"
#extract bsps

EXTERNALHDFPATH="/workspaces1/ckalluri/yocto/hdf-examples/"

#for bsp in ${BSPS}
#do
#	BSPNAME="xilinx-v"+${RELYEAR}+"-final.bsp"
#	EXTRACTEDBSP="xilinx-"+${bsp}+"-"+${RELYEAR}
#	tar -xvf ${BSPPATH}/${BSPNAME}
#	cp ${EXTRACTEDBSP}/${XSAPATH} ${EXTERNALHDFPATH}/ 
#done



#zynq bsps
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zc702-v${RELYEAR}-final.bsp 
cp xilinx-zc702-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zc702-zynq7/

tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zc706-v${RELYEAR}-final.bsp 
cp xilinx-zc706-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zc706-zynq7/

#zynqmp bsps
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zcu102-v${RELYEAR}-final.bsp 
cp xilinx-zcu102-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zcu102-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zcu104-v${RELYEAR}-final.bsp 
cp xilinx-zcu104-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zcu104-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zcu106-v${RELYEAR}-final.bsp 
cp xilinx-zcu106-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zcu106-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zcu111-v${RELYEAR}-final.bsp 
cp xilinx-zcu111-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zcu111-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zcu1275-v${RELYEAR}-final.bsp 
cp xilinx-zcu1275-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zcu1275-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zcu1285-v${RELYEAR}-final.bsp 
cp xilinx-zcu1285-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zcu1285-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-ultra96-reva-v${RELYEAR}-final.bsp 
cp xilinx-ultra96-reva-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/ultra96-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zcu100-v${RELYEAR}-final.bsp 
cp xilinx-zcu100-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zcu100-zynqmp/

#versal bsps
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-v350-DC01-v${RELYEAR}-final.bsp 
cp xilinx-v350-DC01-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/v350-versal/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-vck5000-v${RELYEAR}-final.bsp 
cp xilinx-vck5000-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/vck5000-versal/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-vmk180-v${RELYEAR}-final.bsp 
cp xilinx-vmk180-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/vmk180-versal/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-zc1751-dc1-v${RELYEAR}-final.bsp 
cp xilinx-zc1751-dc1-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zc1751-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-vck190-v${RELYEAR}-final.bsp
cp xilinx-vck190-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/vck190-versal/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-vck190-SC-v${RELYEAR}-final.bsp 
cp xilinx-vck190-SC-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/vck-sc-zynqmp/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-vc-p-a2197-00-reva-x-prc-01-reva-v${RELYEAR}-final.bsp
cp xilinx-vc-p-a2197-00-reva-x-prc-01-reva-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/vc-p-a2197-00-versal/

#other
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/avnet-digilent-zedboard-v${RELYEAR}-final.bsp 
cp avnet-digilent-zedboard-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/zedboard-zynq7/
tar -xf /proj/petalinux/${RELYEAR}/petalinux-v${RELYEAR}_daily_latest/bsp/release/xilinx-kc705-v${RELYEAR}-final.bsp 
cp xilinx-kc705-${RELYEAR}/${XSAPATH} ${EXTERNALHDFPATH}/kc705-microblazeel/

