#!/bin/sh
cd /scratch/ckalluri/DAILY/
python3 /scratch/ckalluri/scripts/yocto-scripts/daily-builds/daily_commit_update_script.py /scratch/ckalluri/scripts/yocto-scripts/daily-builds/details_2020.3.log | tee 2020.3.log
python3 /scratch/ckalluri/scripts/yocto-scripts/daily-builds/daily_commit_update_script.py /scratch/ckalluri/scripts/yocto-scripts/daily-builds/details_2020.2.2_SOM.log | tee SOM.log
python3 /scratch/ckalluri/scripts/yocto-scripts/daily-builds/daily_commit_update_script.py /scratch/ckalluri/scripts/yocto-scripts/daily-builds/details_2021.log | tee 2021.log
