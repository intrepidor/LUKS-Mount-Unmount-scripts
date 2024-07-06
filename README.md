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
sdX      8:48   0  7.3T  0 disk
├─sdX1   8:49   0  1.9G  0 part
└─sdX2   8:50   0  7.3T  0 part
</pre>

4. Create LUKS container
<pre>
sudo cryptsetup luksFormat /dev/sdX2  # Enter passphrase when requested
</pre>

5. Create filesystems
<pre>
sudo mkfs.ext4 /dev/sdX1
sudo cryptsetup open /dev/sdX2 USB_EXT_RSYNC_A    # open the partition and assign label = USB_EXT_RSYNC_A
</pre>
<pre>
$ lsblk -f /dev/sdX
NAME                FSTYPE      FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sdX
├─sdX1              ext4        1.0         b1d064d3-341e-4bea-95ee-3e571c3358e4
└─sdX2              crypto_LUKS 2           84002acf-f2d2-4158-8bb5-c35cb31450ab
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

8. Optionally add details to /etc/fstab
Add the following to /etc/fstab
<pre>
UUID=b1d064d3-341e-4bea-95ee-3e571c3358e4                  /mnt/info ext4  defaults,nofail 0 0
UUID=/dev/mapper/luks-84002acf-f2d2-4158-8bb5-c35cb31450ab /mnt/data btrfs defaults,noatime,compress=zstd:1,nofail 0 0
</pre>
10. Setup unencrypted partition
<pre>LUKS-Mount-Unmount-scripts
$ lsblk -f /dev/sdX
NAME   FSTYPE      FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sdX
├─sdX1 ext4        1.0         b1d064d3-341e-4bea-95ee-3e571c3358e4
└─sdX2 crypto_LUKS 2           84002acf-f2d2-4158-8bb5-c35cb31450ab
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

10. Test
Mount the encrypted partition
<pre>
sudo ./mount_encrypted_partition.sh   # enter pass phrase when requested

#1 Creating mount point as /mnt/USB_RSYNC_A
/dev/disk/by-uuid/84002acf-f2d2-4158-8bb5-c35cb31450ab

#2 Unlocking LUKS container UUID=84002acf-f2d2-4158-8bb5-c35cb31450ab as USB_RSYNC_A
Enter passphrase for /dev/disk/by-uuid/84002acf-f2d2-4158-8bb5-c35cb31450ab: 

#3 Mounting the partition found inside the LUKS container to /mnt/USB_RSYNC_A

SUCCESS: partition inside LUKS container mounted to /mnt/USB_RSYNC_A
</pre>
<pre>
$ lsblk /dev/sdX
NAME            MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sdX               8:48   0  7.3T  0 disk
├─sdX1            8:49   0  1.9G  0 part  /mnt/info
└─sdX2            8:50   0  7.3T  0 part
└─USB_RSYNC_A 252:2    0  7.3T  0 crypt /mnt/USB_RSYNC_A      
</pre>

11. Unmount the encrypted partition
<pre>
$ sudo ./unmount_encrypted_partitions.sh

#1 Unmounting partition /dev/mapper/USB_RSYNC_A from LUKS container

#2 Locking LUKS container USB_RSYNC_A
Device /dev/mapper/USB_RSYNC_A is not active.

#3 Unmounting partition (uuid=84002acf-f2d2-4158-8bb5-c35cb31450ab) containing LUKS container

SUCCESS: LUKS container partition unmounted and container closed.
</pre>
