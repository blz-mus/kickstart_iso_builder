# create_centos_iso

This script is tested on Ubuntu 20.04.1 LTS. It downloads "CentOS-7-x86_64-Minimal-2009.iso" to a working dir then it creates a bootable Centos 7.9 image that contains your customized kickstart file.

## How to use this script : 

   * ./create_centos_iso prepare      :   Create necessary working folders & download the Minimal Centos ISO if it doesn't exists
   * ./create_centos_iso clean        :   Unmount ISO and Delete working folders Iso_dir & Mount_dir
   * ./create_centos_iso create       :   Create the new ISO image