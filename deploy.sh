#!/bin/sh
#
# Deploys sharpen_pitest to ~/bin

cp pitest ~/bin
chmod a+x ~/bin/pitest

cp pitest.java ~/bin
cp jpitest ~/bin
chmod a+x ~/bin/jpitest

cp sharpen_pitest.rb ~/bin
chmod a+x ~/bin/sharpen_pitest.rb
