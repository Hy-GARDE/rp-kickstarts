#Add your custom project specific application's name in this file.

# FIXME - temporary fix about problem that don't enable -update release
%post --log /tmp/post-fix_distro_repos

RP_RELEASE="redpesk-lts-corn-3.0-update"
# RP_RELEASE="redpesk-lts-corn-3.0.0"

echo "Switch to ${RP_RELEASE} release"
if [[ "${RP_RELEASE}" == "redpesk-lts-corn-3.0-update" ]]; then
    echo "Switch on corn-3.0-update release"
    echo "0" > /etc/dnf/vars/redpesk_releasefull
    echo "1" > /etc/dnf/vars/redpesk_update
elif [[ "${RP_RELEASE}" == "redpesk-lts-corn-3.0.0" ]]; then
    echo "1" > /etc/dnf/vars/redpesk_releasefull
    echo "0" > /etc/dnf/vars/redpesk_update
else
    echo "Unsupported ${RP_RELEASE} release"
    exit 1
fi
%end

%packages --ignoremissing --nocore --exclude-weakdeps
#CUSTOM PACKAGES for HYGARDE project needs
hygarde-project-repos
hygarde-image-config
postgresql-server
timescaledb-2-postgresql-16
opensc
openct
openssl
openssl-pkcs11-backport
fsverity-utils
# FIXME - keyutils should be removed in final production image
keyutils
%end

# Enable openct service
%post --erroronfail
echo "Enabling openct service..."
systemctl enable openct.service
%end

# Setup SMACK labels for postgresql
%post --log /tmp/post-postgresql
/bin/sh -c '([ ! -d /var/lib/pgsql ] || chsmack -a System -r /var/lib/pgsql)'
/bin/sh -c '([ -d /var/run/postgresql ] && rmdir /var/run/postgresql; mkdir /var/run/postgresql; chown postgres:postgres /var/run/postgresql)'
%end
