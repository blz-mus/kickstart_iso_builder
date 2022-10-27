# **KIB : `Kickstart Iso Builder` **

1. This script is tested on Ubuntu 20.04.1 LTS 
2. it premets to create a customized bootable UEFI/BIOS with kickstart for Red-Hat RHEL7 RHEL8 / CentOS7 CentOS8 image
3. it permets to download the image if it doesn't exist 
4. Kickstart fails to format the boot disk for CISCO UCS C220 M5: https://access.redhat.com/solutions/3081331



## How to use this script : 
```
   - sudo bash ./kickstart_iso_builder.sh create               :   Create the new ISO image
   - sudo bash ./kickstart_iso_builder.sh prepare              :   Create necessary working folders & download the Minimal Centos ISO if it doesn't exists
   - sudo bash ./kickstart_iso_builder.sh clean                :   Unmount ISO and Delete working folders $MOUNT_DIR & $ISO_COPY_DIR

   - ./create_centos_iso.sh -h | --help | help :   Show help
```