#!/bin/bash

set -e

apt-get update
# apt-get -y install zfsutils-linux
# apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
# apt-get update
# dd if=/dev/zero of=/var/lib/docker_zfs.img bs=1M count=8192
# zpool create -f zroot /var/lib/docker_zfs.img
# zfs create -o mountpoint=/var/lib/docker zroot/docker
# apt-get install -y docker-engine
apt-get install -y letsencrypt strongswan
apt-get install vim
apt-get install -y apparmor-utils
aa-disable /usr/lib/ipsec/charon
iptables -t nat  -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE

echo droplet phone : PSK \"${1}\" >> /etc/ipsec.secrets
echo "syntax on" >> /root/.vimrc
cat <<EOF > /etc/strongswan.conf
# /etc/strongswan.conf - strongSwan configuration file

charon {
	load_modular = yes

	dns1 = 8.8.8.8
	dns2 = 8.8.4.4

	plugins {
		include strongswan.d/charon/*.conf
	}
}

include strongswan.d/*.conf
EOF

IP_ADDRESS=$(curl http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

cat <<EOF > /etc/ipsec.conf
# /etc/ipsec.conf - strongSwan IPsec configuration file
config setup
#  charondebug = "ike 2, cfg 1, enc 2"

conn %default
	ikelifetime=60m
	keylife=20m
	rekeymargin=3m
	keyingtries=1
	keyexchange=ikev2
	authby=secret

conn rw
	left=$IP_ADDRESS
	leftsubnet=0.0.0.0/0
	leftfirewall=yes
	keyexchange=ikev2
	right=%any
	rightsourceip=10.0.0.0/24
	dpdaction=clear
	leftid=droplet
	rightid=phone
	auto=add
 	ike=aes256-sha256-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024! # Win7 is aes256, sha-1, modp1024; iOS is aes256, sha-256, modp1024; OS X is 3DES, sha-1, modp1024
	esp=aes256-sha256,aes256-sha1,3des-sha1! # Win 7 is aes256-sha1, iOS is aes256-sha256, OS X is 3des-shal1
	rekey=no
EOF


service strongswan start

sleep 10

service strongswan restart
