# create_centos_iso

This script is tested on Ubuntu 20.04.1 LTS. It helps to download "CentOS-7-x86_64-Minimal-2009.iso" on a working dir then creates a bootable Centos 7.9 image that contains the good kickstart file.

## How to use this script : 

   * ./create_centos_iso prepare      :   Create necessary folder to create your custom ISO & download the ISO if it doesn't exists 
   * ./create_centos_iso clean        :   Unmount ISO and Delete working folders Iso_dir & Mount_dir
   * ./create_centos_iso create       :   Create the new ISO image