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
%post --nochroot --logfile=/tmp/post-fsverity.log --erroronfail
echo "Adapting rootfs partition to support verity features..."
tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.rootfs" | cut -f1 -d:)
# FIXME tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.usr" | cut -f1 -d:)
# FIXME tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.etc" | cut -f1 -d:)
tune2fs -O verity $(blkid /dev/mapper/Redpesk-OS* | grep "LABEL=.data" | cut -f1 -d:)
%end

# Setup boot.scr used by uboot
# /dev/mmcblk1p2 match partition / defined above
%packages --ignoremissing --nocore --exclude-weakdeps
uboot-tools
%end

%post --logfile=/tmp/post-uboot-bootscr.log --erroronfail
echo "Boot into normal mode..."
cat <<'EOF' > /boot/bootscript.txt
setenv mmcdev 1
setenv mmcpart 1
setenv mmcroot /dev/mmcblk1p2 rootwait rw
setenv bootargs ${jh_clk} console=${console} root=${mmcroot} security=smack nohz_full=2 irqaffinity=0-1,3 rcu_nocbs=2 rcu_nocb_poll nosoftlockup
load mmc ${mmcdev}:${mmcpart} ${loadaddr} Image
load mmc ${mmcdev}:${mmcpart} ${fdt_addr_r} imx8mp-hummingboard-pulse.dtb
booti ${loadaddr} - ${fdt_addr_r}
EOF
mkimage -A arm -C none -T script -O u-boot -n "Redpesk boot script" -d /boot/bootscript.txt /boot/boot.scr
cat /boot/bootscript.txt

dnf remove -y uboot-tools
%end

# Correctly set UUID in /etc/fstab
%post --nochroot --logfile=/tmp/post-fstab.log --erroronfail
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
cat /mnt/sysroot/etc/fstab
%end


# /tmp and /var/tmp as tmpfs
%post --logfile=/tmp/post-tmp.log --erroronfail
echo "Enabling tmpfs for /tmp..."
systemctl enable tmp.mount
systemctl enable var-tmp.mount
%end
