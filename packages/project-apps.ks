#Add your custom project specific application's name in this file.

%packages
#CUSTOM PACKAGES LIST WILL COME HERE
NetworkManager-ppp
NetworkManager-wwan
hygarde-bsp-config
postgresql-server
iproute-tc
%end

%post --log /tmp/post-postgresql
/bin/sh -c '([ ! -d /var/lib/pgsql ] || chsmack -a System -r /var/lib/pgsql)'
/bin/sh -c '([ -d /var/run/postgresql ] && rmdir /var/run/postgresql; mkdir /var/run/postgresql; chown postgres:postgres /var/run/postgresql)'
%end
