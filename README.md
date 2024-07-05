# How to create an external LUKS encrypted USB disk

1. Start with an empty External USB drive

2. Configure the drive with two partitions.
<pre>
sudo parted /dev/sdX
mkpart info ext4 1mb 2gb    # make 2gb partition that will not be encrypted
mkpart data ext4 2gb 100%   # use remainder of disk for LUKS partition
align-check opt 1           # verify partitions are optimally aligned
align-check opt 2           # verify partitions are optimally aligned
print                       # verify all looks correct, including disk = GPT
q                           # quit
</pre>

3. Check results
<pre>
$ lsblk /dev/sdX
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sdd      8:48   0  7.3T  0 disk
├─sdX1   8:49   0  1.9G  0 part
└─sdX2   8:50   0  7.3T  0 part
</pre>

4. Create LUKS container
<pre>
sudo cryptsetup luksFormat /dev/sdX2  # Enter passphrase when requested
</pre>

5. Create filesystem in LUKS container
<pre>
sudo cryptsetup open /dev/sdX2 USB_EXT_RSYNC_A    # open the partition and assign label = USB_EXT_RSYNC_A
</pre>
<pre>
$ lsblk -f /dev/sdX
NAME                FSTYPE      FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sdd
├─sdX1              ext4        1.0         bed054d9-368e-4aed-92ed-9e278c3098e5
└─sdX2              crypto_LUKS 2           9d19d0fc-f2d2-4158-8bb5-c13abc1dc090
└─USB_EXT_RSYNC_A
</pre>
<pre>
sudo mkfs.btrfs /dev/mapper/USB_EXT_RSYNC_A     # format the partition using BRTFS
</pre>

6. Test mount the partition
<pre>
   sudo mkdir /mnt/scratch
   sudo mount -t btrfs /dev/mapper/USB_EXT_RSYNC_A /mnt/scratch 
</pre>        

7. Clean up
<pre>
   sudo umount /mnt/scratch
   sudo cryptsetup close USB_EXT_RSYNC_A
   # or
   sudo cryptsetup close /dev/mapper/USB_EXT_RSYNC_A
</pre>

10. Setup unencrypted partition
<pre>LUKS-Mount-Unmount-scripts
$ lsblk -f /dev/sdX
NAME   FSTYPE      FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sdd
├─sdX1 ext4        1.0         bed054d9-368e-4aed-92ed-9e278c3098e5
└─sdX2 crypto_LUKS 2           9d19d0fc-f2d2-4158-8bb5-c13abc1dc090
</pre>

<pre>
sudo mkdir /mnt/{info,data}
sudo mount -t ext4 /dev/sdX1 /mnt/info
cd /mnt/info && sudo git clone https://github.com/intrepidor/LUKS-Mount-Unmount-scripts.git
cd /mnt/info && sudo mv LUKS-Mount-Unmount-scripts/*.sh .
sudo rm -rf /mnt/info/LUKS-Mount-Unmount-scripts
sudo chmod +x *.sh
</pre>

Configure variables.sh file. Use config.sh as a helper.
<pre>
   sudo /mnt/info/config.sh -l USB_EXT_RSYNC_A -d /dev/sdX -f btrfs > ./variables.sh
</pre>

Delete config.sh afterwards to future mistakes

<pre>
   sudo rm /mnt/info/config.sh
</pre>
