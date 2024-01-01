#!/bin/bash

source ./variables.sh

cd
echo && echo "#1 Unmounting partition /dev/mapper/$DEV_MAPPER_NAME from LUKS container"
sudo umount "$MOUNTPOINT" 2>/dev/null

TMPA=$(mount|grep "$MOUNTPOINT")
if [ -n "$TMPA" ]; then
    echo "ERROR: Unable to unmount partition inside of LUKS container.";
else
    echo && echo "#2 Locking LUKS container $DEV_MAPPER_NAME"; 
    sudo cryptsetup close "$DEV_MAPPER_NAME";
    sudo cryptsetup close /dev/mapper/"$DEV_MAPPER_NAME";

    TMPB=$(ls /dev/mapper/"$DEV_MAPPER_NAME" 2>/dev/null);
    if [ -n "$TMPB" ]; then
        echo "ERROR: Unable to lock LUKS container $DEV_MAPPER_NAME";
    else
        echo && echo "#3 Unmounting partition (uuid=$UUID) containing LUKS container";
        TMPC=$(ls /dev/disk/by-uuid/"$UUID");
        if [ -n "$TMPC" ]; then
            sudo umount "$MOUNTPOINT" 2>/dev/null;
            sudo umount /dev/mapper/"$DEV_MAPPER_NAME" 2>/dev/null;
        else
            echo "ERROR: Unable to find partition UUID=$UUID.";
        fi
        TMPD=$(ls /dev/mapper/"$DEV_MAPPER_NAME" 2>/dev/null);
        if [ -n "$TMPD" ]; then
            echo "ERROR: Partition $UUID still mounted.";
        else
            TMPE=$(mount|grep "$MOUNTPOINT");
            if [ -z "$TMPE" ]; then
                echo && echo "SUCCESS: LUKS container partition unmounted and container closed.";
            else
                echo && echo "$TMPE" && echo "ERROR: LUKS container closed, but LUKS partition still mounted.";
            fi
        fi
    fi
fi
