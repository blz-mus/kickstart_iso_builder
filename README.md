
- [1. *`KIB`* : *Kickstart ISO Builder*](#1-kib--kickstart-iso-builder)
- [2. *How to use this script*](#2-how-to-use-this-script)
- [3. *Kickstart files*](#3-kickstart-files)

# 1. *`KIB`* : *Kickstart ISO Builder*

1. This script is tested on Ubuntu 20.04.1 LTS 
2. It premets to create a customized bootable UEFI/BIOS with kickstart for Red-Hat RHEL7 RHEL8 / CentOS7 CentOS8 image
3. It permets to download the image if it doesn't exist 
4. Official RedHat Documentation : https://access.redhat.com/solutions/60959
5. Kickstart fails to format the boot disk for CISCO UCS C220 M5: https://access.redhat.com/solutions/3081331



# 2. *How to use this script* 
```
   - sudo bash ./kickstart_iso_builder.sh create  :   Create the new ISO image
   - sudo bash ./kickstart_iso_builder.sh prepare :   Create necessary working folders & download the Minimal Centos ISO if it doesn't exists
   - sudo bash ./kickstart_iso_builder.sh clean   :   Unmount ISO and Delete working folders $MOUNT_DIR & $ISO_COPY_DIR
   - sudo bash ./create_centos_iso.sh -h | --help | help :   Show help
```

# 3. *Kickstart files* 

- *kickstart_RHEL8.cfg* : install RHEL8 on KVM Guest**
- *kickstart_RHEL7.cfg* : install RHEL7 on KVM Guest
- *kickstart_RHEL7_UCS_C220.cfg* : install RHEL7 on Cisco UCS C220 M5