#!/bin/bash

source variables.sh

TMPA=$(mount|grep "$MOUNTPOINT")
echo $TMPA
if [ -n "$TMPA" ]; then 
    echo "ERROR: $MOUNTPOINT already in use";
else
    echo && echo "#1 Creating mount point as $MOUNTPOINT";
    mkdir -p "$MOUNTPOINT";

    TMPB=$(ls /dev/disk/by-uuid/$UUID 2>/dev/null)
    echo $TMPB
    if [ -z "$TMPB" ]; then
       echo "ERROR: LUKS container UUID=$UUID not found";
    else
        echo && echo "#2 Unlocking LUKS container UUID=$UUID as $DEV_MAPPER_NAME";
        sudo cryptsetup open /dev/disk/by-uuid/$UUID "$DEV_MAPPER_NAME";
        TMPC=$(ls -la /dev/mapper/"$DEV_MAPPER_NAME" 2>/dev/null);
        echo;
        if [ -n "$TMPC" ]; then
            echo "#3 Mounting the partition found inside the LUKS container to $MOUNTPOINT";
            sudo mount -t "$FSTYPE" /dev/mapper/"$DEV_MAPPER_NAME" "$MOUNTPOINT";
            TMPD=$(mount|grep "$MOUNTPOINT");
            echo;
            if [ -n "$TMPD" ]; then
                echo "SUCCESS: partition inside LUKS container mounted to $MOUNTPOINT";
            else
                echo "ERROR: Failed to mount partition inside LUKS container.";
            fi
        else
            echo "ERROR: Failed to unlock LUKS container UUID=$UUID";
        fi
    fi
fi
