%packages --ignoremissing --nocore --exclude-weakdeps

# no dev/tune tools
-tuned
-ethtool
-dmidecode

# not wireless
-iw
-wireless-regdb

# no examples
# FIXME to remove in next version: -helloworld-binding
%end


%post --erroronfail --log /tmp/post-clean.log

# Disable dnf make cache timer (no need in prod)
rm /etc/systemd/system/timers.target.wants/dnf-makecache.timer
sed -i '/^\[main\]/a metadata_timer_sync=0' /etc/dnf/dnf.conf

%end
