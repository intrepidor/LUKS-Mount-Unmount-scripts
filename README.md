# How to create an external LUKS encrypted USB disk

1. Start with an empty External USB drive
2. Configure the drive with two partitions.
<pre>
   sudo parted
   mkpart prim ext4 1mb 4gb    # make 4gb partition that will not be encrypted
   mkpart prim ext4 4gb 100%   # use remainder of disk for LUKS partition
   align-check opt 1           # verify partitions are optimally aligned
   align-check opt 2           # verify partitions are optimally aligned
   print                       # verify all looks correct, including disk = GPT
   q                           # quit
</pre>
4. Confirm again
   <pre>
    $ lsblk /dev/sdd
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    sdd      8:48   0  7.3T  0 disk
    ├─sdd1   8:49   0  3.7G  0 part
    └─sdd2   8:50   0  7.3T  0 part
</pre>
6. Create LUKS container
<pre>
    sudo cryptsetup luksFormat /dev/sdd2  # Enter passphrase when requested
</pre>
7. Format LUKS container
<pre>
    sudo cryptsetup open /dev/sdd2 USB_EXT_RSYNC_A    # open the partition and assign label = USB_EXT_RSYNC_A
    $ lsblk /dev/sdd
    NAME                MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
    sdd                   8:48   0  7.3T  0 disk
    ├─sdd1                8:49   0  3.7G  0 part
    └─sdd2                8:50   0  7.3T  0 part
    └─USB_EXT_RSYNC_A 252:2    0  7.3T  0 crypt
    sudo mkfs.btrfs /dev/mapper/USB_EXT_RSYNC_A     # format the partition using BRTFS
</pre>
8. Test mount the partition
<pre>
   sudo mkdir /mnt/scratch
   sudo mount -t btrfs /dev/mapper/USB_EXT_RSYNC_A /mnt/scratch 
</pre>        
9. Clean up
<pre>
   sudo umount /mnt/scratch
   sudo cryptsetup close /dev/mapper/USB_EXT_RSYNC_A
</pre>
   
