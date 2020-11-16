
shell_cmd='git status | cut -d ">" -f 2 | tail -n +6 | head -n -13  > upgrade_file_list.log'
os.system(shell_cmd)

pkgs = [line.strip().split('_')[0] for line in open('upgrade_file_list.log')]


data='MACHINE="zcu102-zynqmp"'

with open(os.path.join(basepath,'conf/local.conf'),'a') as f:
        f.write(data)

shutil.copyfile("/workspaces/ckalluri/yocto/Xilinx_master/build/conf/bblayers.conf", "/workspaces/ckalluri/yocto/Xilinx_master/builds-upgrade/conf/bblayers.conf")
for pkg in pkgs:
	os.chdir(basepath)
	os.system('source sources/core/oe-init-build-env builds-upgrade  >& /dev/null;' + 'bitbake %s | tee %s_log.txt'%(pkg,pkg))

