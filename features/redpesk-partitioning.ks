# Note that only 3 primary parts are available (the 4th is used to create the extended parts)

# Setup specific partition scheme of redpesk
# /boot defined in boards/nxp/imx.ks
part /      	--fstype ext4 --size 3072   --label=rootfs  --fsoptions="noatime,rw"
# FIXME - no longer boot: problematic with /usr/sbin/init that is not mounted
# FIXME part /usr  		--fstype ext4 --size 2048   --label=usr 	--fsoptions="noatime,nodev,rw"					 # FIXME - must be RO for final prod image
# FIXME part /etc  		--fstype ext4 --size 1200   --label=etc 	--fsoptions="noatime,nodev,nosuid,noexec,rw"	 # FIXME - must be RO for final prod image
part /var/log  	--fstype ext4 --size 2048   --label=logs    --fsoptions="noatime,nodev,nosuid,noexec,rw"
part /data  	--fstype ext4 --size 6144   --label=data    --fsoptions="noatime,nodev,nosuid,noexec,rw"

# enable fsverify and rewrite /etc/fstab UUIDs
%post --nochroot --logfile=/mnt/sysroot/tmp/post-fstab.log --erroronfail
echo "Adapting rootfs partition to support verity features..."
tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.rootfs" | cut -f1 -d:)
# FIXME tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.usr" | cut -f1 -d:)
# FIXME tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.etc" | cut -f1 -d:)
tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.data" | cut -f1 -d:)
%end

# Set UUID in /etc/fstab
%post --nochroot --logfile=/mnt/sysroot/tmp/post-fstab.log --erroronfail
echo "Setting UUID into /etc/fstab..."
grep "^/dev.*Redpesk*" /mnt/sysroot/etc/fstab | while read part ; do
	dev=$(echo $part | cut -d' ' -f1)
	label=$(echo $part | cut -d' ' -f2)
	label="${label##*/}"
	if [[ "$label" == "" ]]; then
		label="rootfs"
	elif [[ "$label" == "efi" ]]; then
		label="EFI"
	fi
	UUID=$(blkid -s UUID -o value `blkid -L $label`)
	echo "dev=$dev UUID=$UUID label=$label"
	sed -i "s|${dev}|UUID=\"${UUID}\"|g" /mnt/sysroot/etc/fstab
done
%end


# /tmp and /var/tmp as tmpfs
%post --logfile=/mnt/sysroot/tmp/post-tmp.log --erroronfail
echo "Enabling tmpfs for /tmp..."
systemctl enable tmp.mount
systemctl enable var-tmp.mount
%end
