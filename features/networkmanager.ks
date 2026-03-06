
# No wifi enable for Hygarde production image
# %packages --ignoremissing --nocore --exclude-weakdeps
# NetworkManager-wifi

# %end

%pre-install
# disable systemd-networkd
mkdir -p /mnt/sysimage/etc/systemd/system-preset
cat <<EOF > /mnt/sysimage/etc/systemd/system-preset/10-disable-networkd.preset
disable systemd-networkd.service
disable systemd-networkd-wait-online.service
EOF
%end
