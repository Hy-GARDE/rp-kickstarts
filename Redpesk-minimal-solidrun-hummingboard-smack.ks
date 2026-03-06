# BSP / core redpesk
%include boards/solidrun/imx8mp-hummingboard.ks
%include distro/redpesk-bsp.ks
%include distro/redpesk-core.ks
# FIXME - disable recovery for now
# %include features/recovery.ks

# 1st optimizations
%include features/reduce_size.ks
%include distro/redpesk-minimal.ks

# add security and network
%include features/smack.ks
%include features/extract_logs.ks
%include features/networkmanager.ks

# addition steps for production ready image
%include features/reduce_size_prod.ks

# Disabling bootloader for ARM images
bootloader --location=none --disabled

# See packages/* files for HYGARDE apps + bindings setup
