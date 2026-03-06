%packages --ignoremissing --nocore --exclude-weakdeps

# no dev/tune tools
# FIXME to remove in next version: -uboot-tools
-tuned
-ethtool
-dmidecode

# not wireless
-iw
-wireless-regdb

# no examples
# FIXME to remove in next version: -helloworld-binding

%end

