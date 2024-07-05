#!/bin/sh

usage() {
    echo "Usage:   ${0} -d <device> -f <fstype> -l <label>"
    echo "Example: ${0} -d /dev/sdd -f brtfs -l USB_RSYNC_A"
    echo
}

xerr=""
while getopts "hf:l:d:" option; do
    case $option in
        h) #display help
            usage
            exit;;
        f) # fstype
           xfstype=$OPTARG;;
        l) # label
            xlabel=$OPTARG;;
        d) # device id
            xdevice=$OPTARG;;
        \?) #error
            xerr="true";;
    esac
done
shift $((OPTIND-1))

if [ -z "${xfstype}" ] || [ -z "${xlabel}" ] || [ -z "${xdevice}" ]; then
    usage
fi

if [ -z "${xerr}" ]; then
    uuid=$(lsblk ${xdevice} -f|grep crypto_LUKS|awk '{print $4}');
    echo "MOUNTPOINT=/mnt/${xlabel}";
    echo "UUID=${uuid}";
    echo "DEV_MAPPER_NAME=${xlabel}";
    echo "FSTYPE=${xfstype}";
fi
