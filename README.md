# create_centos_iso

This script is tested on Ubuntu 20.04.1 LTS. It downloads "CentOS-7-x86_64-Minimal-2009.iso" to a working dir then it creates a bootable Centos 7.9 image that contains your customized kickstart file.

BIOS && UEFI boot 
Kickstart for CISCO UCS C220 M5

## How to use this script : 

   * sudo bash ./kickstart_iso_builder.sh create               :   Create the new ISO image
   * sudo bash ./kickstart_iso_builder.sh prepare              :   Create necessary working folders & download the Minimal Centos ISO if it doesn't exists
   * sudo bash ./kickstart_iso_builder.sh clean                :   Unmount ISO and Delete working folders $MOUNT_DIR & $ISO_COPY_DIR

   * ./create_centos_iso.sh -h | --help | help :   Show help
