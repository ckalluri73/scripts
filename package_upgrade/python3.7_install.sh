#!/bin/sh

wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz
tar xvf Python-3.7.0.tar.xz
cd Python37/Python-3.7.0
ls
cd Python-3.7.0
./configure --enable-optimizations
sudo apt-get install libffi-dev
sudo -H make altinstall

