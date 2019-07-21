#!/usr/bin/sh
Usage(){
    echo "USAGE: /bin/bash pwd should be at outside of torque-4.2.9"
    echo "USAGE: The first argument should be the ip or name of the host"
    echo "USAGE: The host should be free passwd with ssh to all the other hosts"
}
Set(){
	wget ¨Cc http://wpfilebase.s3.amazonaws.com/torque/torque-4.2.9.tar.gz
	tar -zxvf torque-4.2.9.tar.gz
	cd torque-4.2.9
	yum install libxml2-devel openssl-devel gcc gcc-c++ boost-devel libtool -y
	./configure --prefix=/usr/local/torque-4.2.9 --with-scp --with-default-server=$1 && make && make packages && make install
	cp contrib/init.d/{pbs_{server,sched,mom},trqauthd} /etc/init.d/
	for i in pbs_server pbs_sched pbs_mom trqauthd; do chkconfig --add $i; chkconfig $i on; done
	TORQUE=/usr/local/torque-4.2.9??
	echo "TORQUE=$TORQUE" >>/etc/profile
	echo "export PATH=\$PATH:$TORQUE/bin:$TORQUE/sbin" >>/etc/profile
	source /etc/profile
	./torque.setup devin
	./torque.setup root
	qterm -t quick
	for i in pbs_server pbs_sched pbs_mom trqauthd; do service $i start; done
	mkdir /var/spool/torque/server_priv
	touch /var/spool/torque/server_priv/nodes
	echo $1 >> /var/spool/torque/server_priv/nodes
	mkdir /var/spool/torque/mom_priv
	touch /var/spool/torque/mom_priv/config
	echo "\$pbsserver $i" >> /var/spool/torque/mom_priv/config
	echo "\$logevent 255" >> /var/spool/torque/mom_priv/config
	ps -e | grep pbs
	qnodes
}
main(){
    [ $# -ne 0 ] && {
        Usage
        exit -1
    }
    Set $1
}
main $*
