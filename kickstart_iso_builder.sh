#!/bin/bash
# Edited By : BOULOUZA Moustafa
# update: 2022/10/27
# This script is tested on Ubuntu 20.04.1 LTS 
# it premets to create a customized bootable UEFI/BIOS with kickstart for Red-Hat RHEL7 RHEL8 / CentOS7 CentOS8 image
# it permets to download the image if it doesn't exist 
# Kickstart fails to format the boot disk for CISCO UCS C220 M5: https://access.redhat.com/solutions/3081331

set -e
set -o pipefail
# Moves and copies need to include dot-files. it's important to copy .treeinfo file inside the CD/DVD to $ISO_COPY_DIR
shopt -s dotglob

ISO_PATH_SRC="/media/data/iso" # path to image src folder
ISO_PATH_DST="/media/data/iso" # folder where final customized image will be copied

#RHEL8
#Iso_url="http://calipso.linux.it.umich.edu/pulp/isos/UM/Library/content/dist/rhel8/8/x86_64/baseos/iso/"
#ISO_LABEL="rhel-8.2-x86_64-dvd" # exact image src name without .iso extention
#KS="kickstart_RHEL8.cfg"

#RHEL 7
Iso_url="http://miroir.univ-lorraine.fr/centos/7.9.2009/isos/x86_64/"
ISO_LABEL="CentOS-7-x86_64-Minimal-2009" # exact image src name without .iso extention
WORKING_DIR="/tmp/rhel_custom_iso"
KS="kickstart_RHEL7.cfg"

# Don't change this variables 
ISO_NAME_SRC="${ISO_LABEL}.iso" # exact image src name with .iso extention
ISO_NAME_CUSTOM="${ISO_LABEL}_custom.iso"
MOUNT_DIR="cd_mount"    # folder wher image will be mounted
ISO_COPY_DIR="copy_dir" # folder where iso content is copied
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)


# - Fonctions :
function prepare_working_env() {

    if [ ! -d "$WORKING_DIR"/output ]; then
        mkdir -p "$WORKING_DIR"/output
        echo -e "\n $WORKING_DIR/output is created ... Here you'll find LOG file :-) \n"
    fi

    # - Redirect stdout/stderr to a file :
    exec > >(tee -i "$WORKING_DIR"/output/output_"$(date +"%Y%m%d_%H%M")".log)
    exec 2>&1

    if [ ! -d "$WORKING_DIR"/$MOUNT_DIR ]; then
        mkdir -p "$WORKING_DIR"/$MOUNT_DIR
        echo -e "\n $WORKING_DIR/$MOUNT_DIR is created ... \n"
    fi
    if [ ! -d "$WORKING_DIR"/$ISO_COPY_DIR ]; then
        mkdir -p "$WORKING_DIR"/$ISO_COPY_DIR
        echo -e "\n $WORKING_DIR/$ISO_COPY_DIR is created ... \n"
    fi
    if [ ! -d "$ISO_PATH_DST" ]; then
        mkdir -p "$ISO_PATH_DST"
        echo -e "\n $ISO_PATH_DST is created ... Here you'll find your Customized ISO :-) \n"
    fi

    #    if [ ! -d "$WORKING_DIR"/kickstart ]; then
    #        mkdir -p "$WORKING_DIR"/kickstart
    #        echo -e "\n $WORKING_DIR/kickstart is created ... \n"
    #    fi
    #    if [ ! -d "$WORKING_DIR"/isolinux ]; then
    #        mkdir -p "$WORKING_DIR"/isolinux
    #        echo -e "\n $WORKING_DIR/isolinux is created ... \n"
    #    fi
    if [ ! -e /usr/bin/curl ]; then
        echo -e "\n curl is not installed. Installation starts now ... \n"
        sudo apt-get install curl
    fi
    # Create ISO_PATH_SRC folder and Download the ISO if it doens't exist
    if [ ! -d "$ISO_PATH_SRC" ]; then
        mkdir -p "$ISO_PATH_SRC"
        echo -e "\n $ISO_PATH_SRC is created ... \n"
    fi
    if [ ! -e "$ISO_PATH_SRC"/$ISO_NAME_SRC ]; then
        echo -e "\n No local image copy of $ISO_PATH_SRC/$ISO_NAME_SRC. $ISO_NAME_SRC Will be Downloaded... \n"
        curl -o "$ISO_PATH_SRC"/"$ISO_NAME_SRC" "$Iso_url"/"$ISO_NAME_SRC"
    fi

    cd "$WORKING_DIR"

    ## Mount CD if it doesn't
    if findmnt --mountpoint "$WORKING_DIR"/$MOUNT_DIR -rn; then
        echo -e "\n The ISO is Mounted on $WORKING_DIR/$MOUNT_DIR \n"
    else
        echo -e "\n Mounting ISO on $WORKING_DIR/$MOUNT_DIR ... \n"
        mount -o loop,ro -t iso9660 "$ISO_PATH_SRC"/$ISO_NAME_SRC "$WORKING_DIR"/$MOUNT_DIR
    fi
}

function clean_working_env() {

    echo -e "\n umount $WORKING_DIR/$MOUNT_DIR"
    umount "$WORKING_DIR"/"$MOUNT_DIR"

    if [ -d "$WORKING_DIR"/"$MOUNT_DIR" ]; then
        rm -rf ${WORKING_DIR}/${MOUNT_DIR}
        echo -e "\n $WORKING_DIR/$MOUNT_DIR is deleted ... \n"
    fi

    if [ -d "$WORKING_DIR"/$ISO_COPY_DIR ]; then
        rm -rf $WORKING_DIR/$ISO_COPY_DIR
        echo -e "\n $WORKING_DIR/$ISO_COPY_DIR is deleted ... \n"
    fi
    # uncomment this part if you'd like to remove this folders
    #if [ -d "$WORKING_DIR"/kickstart ]; then
    #    rm -rf "$WORKING_DIR"/kickstart
    #    echo -e "$WORKING_DIR/kickstart is deleted ... \n"
    #fi

    #if [ -d "$WORKING_DIR"/bios_uefi_menu ]; then
    #    rm -rf "$WORKING_DIR"/bios_uefi_menu
    #    echo -e "$WORKING_DIR/bios_uefi_menuis deleted ... \n"
    #fi

}

function modify_boot_menu() {

    ### BIOS Legacy boot
    echo -e "\n ## Modifying BIOS Legacy boot menu in isolinux/isolinux.cfg...."

    if [ -f "$SCRIPT_DIR"/bios_uefi_menu/isolinux.cfg ]; then
        cp -f "$SCRIPT_DIR"/bios_uefi_menu/isolinux.cfg "$WORKING_DIR"/$ISO_COPY_DIR/isolinux/isolinux.cfg
        chmod +rw "$WORKING_DIR"/"$ISO_COPY_DIR"/isolinux/isolinux.cfg
        echo -e "\n The file $SCRIPT_DIR/bios_uefi_menu/isolinux.cfg is copied to  $WORKING_DIR/$ISO_COPY_DIR/isolinux/isolinux.cfg ... \n"
    elif [ ! -e "$SCRIPT_DIR"/bios_uefi_menu/isolinux.cfg ]; then
        echo -e "\n The isolinux.cfg will be downloaded to $SCRIPT_DIR/bios_uefi_menu folder \n"
        curl https://raw.githubusercontent.com/blz-mus/create_centos_iso/main/bios_uefi_menu/isolinux.cfg -o "$SCRIPT_DIR"/bios_uefi_menu/isolinux.cfg
        cp -f "$SCRIPT_DIR"/bios_uefi_menu/isolinux.cfg "$WORKING_DIR"/$ISO_COPY_DIR/isolinux/isolinux.cfg
        chmod +rw "$WORKING_DIR"/"$ISO_COPY_DIR"/isolinux/isolinux.cfg
        echo -e "\n The file $SCRIPT_DIR/bios_uefi_menu/isolinux.cfg is DOWNLOADED and copied to  $WORKING_DIR/$ISO_COPY_DIR/isolinux/isolinux.cfg ... \n"
    else
        echo -e " \n There is no isolinux.cfg. put it please under $SCRIPT_DIR/bios_uefi_menu/ or $WORKING_DIR/$ISO_COPY_DIR/isolinux/. \n"
    fi

    sed -i "s/.*menu title.*/menu title Install $ISO_LABEL /g" $WORKING_DIR/$ISO_COPY_DIR/isolinux/isolinux.cfg
    sed -i "s/.*menu label.*/menu label Install $ISO_LABEL with kickstart LEGACY Boot/g" $WORKING_DIR/$ISO_COPY_DIR/isolinux/isolinux.cfg
    sed -i "s/.*append.* /  append initrd=initrd.img inst.stage2=hd:LABEL=$ISO_LABEL inst.ks=cdrom:\/$KS quiet/g" $WORKING_DIR/$ISO_COPY_DIR/isolinux/isolinux.cfg

    ### UEFI boot menu
    echo -e "\n ## Modifying UEFI boot menu in EFI/BOOT/grub.cfg...."

    if [ -f "$SCRIPT_DIR"/bios_uefi_menu/grub.cfg ]; then
        cp -f "$SCRIPT_DIR"/bios_uefi_menu/grub.cfg "$WORKING_DIR"/"$ISO_COPY_DIR"/EFI/BOOT/grub.cfg
        chmod +rw "$WORKING_DIR"/"$ISO_COPY_DIR"/EFI/BOOT/grub.cfg
        echo -e "\n The file $SCRIPT_DIR/bios_uefi_menu/grub.cfg is copied to  $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/grub.cfg ... \n"
    elif [ ! -e "SCRIPT_DIR"/EFI/BOOT/grub.cfg ]; then
        echo -e "\n The grub.cfg will be downloaded to $SCRIPT_DIR/bios_uefi_menu folder \n"
        curl https://raw.githubusercontent.com/blz-mus/create_centos_iso/main/bios_uefi_menu/grub.cfg -o "$SCRIPT_DIR"/bios_uefi_menu/grub.cfg
        cp -f "$SCRIPT_DIR"/bios_uefi_menu/grub.cfg "$WORKING_DIR"/"$ISO_COPY_DIR"/EFI/BOOT/grub.cfg
        chmod +rw "$WORKING_DIR"/"$ISO_COPY_DIR"/EFI/BOOT/grub.cfg
        echo -e "\n The file $SCRIPT_DIR/bios_uefi_menu/grub.cfg is copied to  $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/grub.cfg ... \n"
    else
        echo -e " \n There is no grub.cfg. put it please under $SCRIPT_DIR/bios_uefi_menu/ or $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/. \n"
    fi

    #KO sed -i "s/menu label.*/menu label Install $ISO_LABEL with kickstart EFI Boot/g" $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/grub.cfg
    sed -i "s/.*menuentry.*/menuentry 'Install $ISO_LABEL with kickstart EFI Boot' --class fedora --class gnu-linux --class gnu --class os {  /g" $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/grub.cfg
    #sed -i "s/linuxefi.* /linuxefi \/images\/pxeboot\/vmlinuz inst.ks=cdrom:\/$KS inst.stage2=hd:LABEL=$ISO_LABEL inst.repo=cdrom  quiet /g" $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/grub.cfg
    #sed -i "s/linuxefi.* /linuxefi \/images\/pxeboot\/vmlinuz inst.ks=cdrom:\/$KS inst.repo=cdrom:LABEL=$ISO_LABEL quiet /g" $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/grub.cfg
    sed -i "s/.*linuxefi.*/linuxefi \/images\/pxeboot\/vmlinuz inst.ks=cdrom:\/$KS inst.stage2=hd:LABEL=$ISO_LABEL quiet /g" $WORKING_DIR/$ISO_COPY_DIR/EFI/BOOT/grub.cfg
}

function create_iso() {

    prepare_working_env

    cd "$WORKING_DIR"

    ## COPY CD Content
    echo -e "\n ## COPY CD Content ..."
    cp -apRf "$WORKING_DIR"/$MOUNT_DIR/* $WORKING_DIR/$ISO_COPY_DIR
    ## COPY Kickstart
    echo -e "\n ## COPY Kickstart ..."

    if [ -e "$SCRIPT_DIR"/kickstart/"$KS" ]; then
        cp "$SCRIPT_DIR"/kickstart/"$KS" "$WORKING_DIR"/"$ISO_COPY_DIR"/
        result="$?"
        if [ "$result" -eq 0 ]; then
            echo -e "\n $KS is copied from $SCRIPT_DIR/kickstart/$KS to $WORKING_DIR/$ISO_COPY_DIR/$KS. \n"
        fi
    #elif [ ! -e "$WORKING_DIR"/"$ISO_COPY_DIR"/$KS ]; then
    #    echo -e " \n CMD : cp $SCRIPT_DIR/kickstart/$KS $WORKING_DIR/$ISO_COPY_DIR/"
    #    cp "$SCRIPT_DIR"/kickstart/$KS $WORKING_DIR/$ISO_COPY_DIR/
    #    echo -e "\n $KS is copied from $SCRIPT_DIR/kickstart/$KS to $WORKING_DIR/$ISO_COPY_DIR/$KS. \n"
    else
        echo -e "\n Please put your $KS file in $SCRIPT_DIR/kickstart/ folder \n"
    fi

    modify_boot_menu

    cd "$WORKING_DIR"/"$ISO_COPY_DIR"
    echo -e "\n Generating ISO with genisoimage \n"

    #  -v : verbose
    genisoimage -U -r -T -J \
        -joliet-long \
        -no-emul-boot \
        -V "$ISO_LABEL" \
        -boot-load-size 4 \
        -boot-info-table \
        -volset "$ISO_LABEL" \
        -A "$ISO_LABEL" \
        -input-charset utf-8 \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -eltorito-alt-boot \
        -e images/efiboot.img \
        -no-emul-boot \
        -x "lost+found" \
        -o $ISO_PATH_DST/$ISO_NAME_CUSTOM .

    echo -e "\n genisoimage is complete ...  \n"

    if [ ! -e /usr/bin/implantisomd5 ]; then
        echo "implantisomd5 is not installed. Installation starts now ..."
        sudo apt install isomd5sum
    fi

    if [ -e "$ISO_PATH_DST"/"$ISO_NAME_CUSTOM" ]; then
        echo -e "\n implantisomd5 $ISO_PATH_DST/$ISO_NAME_CUSTOM \n"
        implantisomd5 $ISO_PATH_DST/$ISO_NAME_CUSTOM

        echo -e "$USER # chmod 777 $ISO_PATH_DST/$ISO_NAME_CUSTOM  \n"
        chmod 777 $ISO_PATH_DST/$ISO_NAME_CUSTOM

        echo -e "Bingooo :-) Your ISO $ISO_PATH_DST/$ISO_NAME_CUSTOM is READY to be used ...  \n"
    else
        echo -e "Oooooops :-( Couldn't Create your ISO \n"
    fi
}

usage() {
    cat <<EOF
usage :
        sudo bash $0 [options] command
options :
  -h              Show this help

commands :
  prepare         Create necessary folder to create your custom ISO 
  create          Create the new ISO image
  clean           Unmount ISO and Delete working folders ISO_COPY_DIR & Mount_dir

usage Example :
  sudo bash $0 prepare 
  sudo bash $0 create
  sudo bash $0 clean
  
EOF
    exit 1
}

while getopts ":h:" n; do
    case "$n" in
    \? | h)
        usage
        exit 0
        ;;
    esac
done
shift $((OPTIND - 1))

subcommand=$1
if [ ! "$subcommand" ]; then
    usage
fi
shift
case "$subcommand" in
prepare)
    prepare_working_env
    ;;
clean)
    clean_working_env
    ;;
create)
    create_iso
    ;;
help)
    usage
    ;;
*)
    echo "Invalid subcommand: $subcommand" 1>&2
    exit 1
    ;;
esac
