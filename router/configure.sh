#!/bin/sh

_step_counter=0
step() {
	_step_counter=$(( _step_counter + 1 ))
	printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2  # bold cyan
}


step 'Set up timezone'
setup-timezone -z US/Pacific

step 'Set up networking'
cat > /etc/network/interfaces <<-EOF
	iface lo inet loopback
	iface eth0 inet dhcp
	iface eth1 inet dhcp
	iface eth2 inet dhcp
EOF

cat > /etc/quagga/ospfd.conf <<EOF
! -*- ospf -*-
!
! OSPFd sample configuration file
!
!
hostname ospfd
password zebra
!enable password please-set-at-here
!
!router ospf
!  network 192.168.1.0/24 area 0
!
log stdout

EOF

cat > /etc/quagga/zebra.conf <<EOF
! -*- zebra -*-
!
! zebra sample configuration file
!
! $Id: zebra.conf.sample,v 1.1 2002/12/13 20:15:30 paul Exp $
!
hostname Router
password zebra
enable password zebra
!
! Interface's description. 
!
!interface lo
! description test of desc.
!
!interface sit0
! multicast
!
! Static default route sample.
!
!ip route 0.0.0.0/0 203.181.89.241
!
!log file zebra.log

EOF

ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0
ln -s networking /etc/init.d/net.eth1
ln -s networking /etc/init.d/net.eth2

step 'Adjust rc.conf'
sed -Ei \
	-e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
	-e 's/^[# ](rc_logger)=.*/\1=YES/' \
	-e 's/^[# ](unicode)=.*/\1=YES/' \
	/etc/rc.conf

step 'Enable services'
rc-update add acpid default
rc-update add chronyd default
rc-update add crond default
rc-update add net.eth0 default
rc-update add net.eth1 default
rc-update add net.eth2 default
rc-update add net.lo boot
rc-update add termencoding boot
rc-update add crond default
rc-update add zebra default
