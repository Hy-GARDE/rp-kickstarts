#Add your custom project specific application's name in this file.

%packages --ignoremissing --nocore --exclude-weakdeps
#CUSTOM PACKAGES for HYGARDE project needs
hygarde-image-config
postgresql-server
timescaledb-2-postgresql-16
iproute-tc
%end

# Setup SMACK labels for postgresql
%post --log /tmp/post-postgresql
/bin/sh -c '([ ! -d /var/lib/pgsql ] || chsmack -a System -r /var/lib/pgsql)'
/bin/sh -c '([ -d /var/run/postgresql ] && rmdir /var/run/postgresql; mkdir /var/run/postgresql; chown postgres:postgres /var/run/postgresql)'
%end
