#!/bin/sh
Usage(){
    echo "USAGE: /bin/bash pwd should be at outside of torque-4.2.9"
    echo "USAGE: The first argument should be the ip or name of the target host"
    echo "USAGE: The target host should be free passwd with ssh"
}
Add(){
	cd ./torque-4.2.9
	ssh root@$1 "mkdir /usr/apps;mkdir /usr/apps/torque-wkr"
	scp torque-package-{mom,clients}-linux-x86_64.sh $1:/usr/apps/torque-wkr/
	scp contrib/init.d/{pbs_mom,trqauthd} $1:/etc/init.d/
	ssh root@$1 "/usr/apps/torque-wkr/torque-package-clients-linux-x86_64.sh --install"
	ssh root@$1 "/usr/apps/torque-wkr/torque-package-mom-linux-x86_64.sh --install"
	scp /var/spool/torque/mom_priv/config root@$1:/var/spool/torque/mom_priv/config
	scp /var/spool/torque/server_priv/nodes root@$1:/var/spool/torque/server_priv/nodes
	scp /var/spool/torque/server_name root@$1:/var/spool/torque/server_name
	ssh root@$1 "for i in pbs_mom trqauthd; do service \$i start; done"
}
main(){
    [ $# -ne 0 ] && {
        Usage
        exit -1
    }
    Add $1
}
main $*
