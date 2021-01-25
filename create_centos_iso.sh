#!/bin/bash

# This script helps you to create a custom Centos 7.9 iso ( Minimal ) that automates installation with kickstart
# adapte your working directory ($Working_dir) and the folder when you want to store your final ISO ($Iso_dst)
# use a valide iso name ($Iso_name) and url (Iso_url), if you want to use another ISO that will be used by this script to download the ISO from internet
# put your kickstart.cfg in kickstart folder ans don't forget to change the ($KS) variable.
#

Working_dir="/media/mus/disk_300/iso/create_centos_iso" 
Mount_dir="cd_mount"
Iso_dir="Iso_dir"
Iso_dst="/media/mus/disk_300/iso"
Iso_label="CentOS-7-x86_64"
Iso_url="http://miroir.univ-paris13.fr/centos/7.9.2009/isos/x86_64/"
Iso_name="CentOS-7-x86_64-Minimal-2009.iso"
Iso_name_CUSTOM="CentOS-7-x86_64-Minimal-2009_custom.iso"
KS="ks3.cfg"


function prepare_working_env() {

    if [ ! -d $Working_dir/$Mount_dir ]; then
        mkdir -p $Working_dir/$Mount_dir
        echo -e "$Working_dir/$Mount_dir is created ... \n"
    fi
    if [ ! -d $Working_dir/$Iso_dir ]; then
        mkdir -p $Working_dir/$Iso_dir
        echo -e "$Working_dir/$Iso_dir is created ... \n"
    fi
    if [ ! -d $Iso_dst ]; then
        mkdir -p $Iso_dst
        echo -e "$Iso_dst is created ... Here you'll find your Customized ISO :-) \n"
    fi
    if [ ! -d $Working_dir/kickstart ]; then
        mkdir -p $Working_dir/kickstart
        echo -e "$Working_dir/kickstart is created ... \n"
    fi
    if [ ! -d $Working_dir/isolinux ]; then
        mkdir -p $Working_dir/isolinux
        echo -e "$Working_dir/isolinux is created ... \n"
    fi
    if [ ! -e /usr/bin/curl ]; then
        echo -e "curl is not installed. Installation starts now ... \n"
        apt-get install curl
    fi
    if [ ! -e $Working_dir/$Iso_name ]; then
        echo -e "No local copy of $Iso_name. Downloading latest $Iso_name ... \n"
        curl -o $Working_dir/$Iso_name $Iso_url/$Iso_name 
    fi

    cd $Working_dir

    ## Mount CD
    mount -t iso9660 -o loop $Working_dir/$Iso_name $Working_dir/$Mount_dir
}

function clean_working_env() {

    umount $Working_dir/$Mount_dir

    if [ -d $Working_dir/$Mount_dir ]; then
        rm -rf $Working_dir/$Mount_dir
        echo -e "$Working_dir/$Mount_dir is deleted ... \n"
    fi
    if [ -d $Working_dir/$Iso_dir ]; then
        rm -rf $Working_dir/$Iso_dir
        echo -e "$Working_dir/$Iso_dir is deleted ... \n"
    fi
    #if [ -d $Working_dir/kickstart ]; then
    #    rm -rf $Working_dir/kickstart
    #    echo -e "$Working_dir/kickstart is deleted ... \n"
    #fi
        #if [ -d $Working_dir/isolinux ]; then
    #    rm -rf $Working_dir/isolinux
    #    echo -e "$Working_dir/isolinux is deleted ... \n"
    #fi

}

function modify_boot_menu() {
    echo "Modifying boot menu ..."
    #cp config/isolinux.cfg $DVD_LAYOUT/isolinux/
    cp $Working_dir/isolinux/isolinux.cfg $Working_dir/$Iso_dir/isolinux/isolinux.cfg
    sed -i "s/menu label.*/menu title Install CentOS 7 with kickstart/g" $Working_dir/$Iso_dir/isolinux/isolinux.cfg
    sed -i "s/append.* /append initrd=initrd.img inst.stage2=hd:LABEL=$Iso_label inst.ks=cdrom:\/$KS quiet/g" $Working_dir/$Iso_dir/isolinux/isolinux.cfg
    
}

function create_iso(){

    prepare_working_env

    cd $Working_dir
    
    ## COPY CD Content
    cp -pRf $Working_dir/$Mount_dir/* $Working_dir/$Iso_dir

    ## COPY Kickstart && isolinux.cfg
    cp $Working_dir/kickstart/* $Working_dir/$Iso_dir/
    
    modify_boot_menu
    
    cd $Working_dir/$Iso_dir

    genisoimage -U -r -v -T -J \
    -joliet-long \
    -no-emul-boot \
    -V "$Iso_label" \
    -boot-load-size 4 \
    -boot-info-table \
    -volset "$Iso_label" \
    -A "$Iso_label" \
    -input-charset utf-8 \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -eltorito-alt-boot \
    -e images/efiboot.img \
    -no-emul-boot \
    -x "lost+found" \
    -o $Iso_dst/$Iso_name_CUSTOM .
    #-o ../../$Iso_name_CUSTOM .

    if [ ! -e /usr/bin/implantisomd5 ]; then
        echo "implantisomd5 is not installed. Installation starts now ..."
        apt install isomd5sum
    fi

    #apt install isomd5sum
    implantisomd5 $Iso_dst/$Iso_name_CUSTOM

    if [ -e $Iso_dst/$Iso_name_CUSTOM ]; then
        echo -e "\n Congratulation you ISO $Iso_name_CUSTOM is created ... \n under $Iso_dst folder"
        else
        echo -e "\n Oooooops Couldn't Create your ISO"

    fi
}


usage() {
    cat << EOF
usage:
        $0 [options] command
options:
  -h, --help, help      Show this help

commands:
  prepare         Create necessary folder to create your custom ISO 
  clean           Unmount ISO and Delete working folders Iso_dir & Mount_dir
  create          Create the new ISO image

EOF
    exit 1
}

while getopts ":h:-help" opt; do
    case ${opt} in
        h )
            usage
            exit 0
            ;;
        -help )
            usage
            exit 0
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

subcommand=$1
if [ ! $subcommand ]; then
    usage
fi
shift
case "$subcommand" in
    prepare )
        prepare_working_env
        ;;
    clean )
        clean_working_env
        ;;
    create )
        create_iso
        ;;
    help )
        usage
        ;;
    * )
        echo "Invalid subcommand: $subcommand" 1>&2
        exit 1
        ;;
esac



#mkdir -p $Working_dir/{$Mount_dir,$Iso_dir}

#sudo umount $Mount_dir

#mkisofs -R -J -T -v -no-emul-boot \
#mkisofs -R -J -T -v -cache-inodes -no-emul-boot \
#    -boot-load-size 4 \
#    -boot-info-table \
#    -V "Centos 7.9 Custom" \
#    -p "Centos 7.9 Custom" \
#    -A "Centos 7.9 Custom" \
#    -b $Iso_dir/isolinux/isolinux.bin \
#    -c $Iso_dir/isolinux/boot.cat \
#    --joliet-long \
#    -o $Working_dir/centos_custom.iso .
# #   -x "lost+found" \

#mkisofs -R -J -v -T -no-emul-boot \
#    -boot-load-size 4 \
#    -boot-info-table \
#    -V "CentOS 7 x86_64" \
#    -b $Iso_dir/isolinux/isolinux.bin \
#    -c $Iso_dir/isolinux/boot.cat \
#    -o ../centos_custom.iso .
 
#mkisofs -o /tmp/boot.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64" -R -J -v -T isolinux/. .



#genisoimage -U -r -v -T -J \ 
#    -joliet-long \
#    -no-emul-boot \
#    -boot-load-size 4 \
#    -boot-info-table \
#    -V "$LABEL" \
#    -volset "$LABEL" \
#    -A "$LABEL" \
#    -b isolinux/isolinux.bin \
#    -c isolinux/boot.cat \
#    -eltorito-alt-boot \
#    -e images/efiboot.img \
##   -no-emul-boot \
#    -o ../../centos_custom.iso .


#mv centos_custom.iso ../





























