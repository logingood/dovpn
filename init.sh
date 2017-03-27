#!/bin/bash
apt-get update
apt-get -y install zfsutils-linux
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
apt-get update
dd if=/dev/zero of=/var/lib/docker_zfs.img bs=1M count=8192
zpool create -f zroot /var/lib/docker_zfs.img 
zfs create -o mountpoint=/var/lib/docker zroot/docker
apt-get install -y docker-engine
apt-get install -y letsencrypt strongswan
apt-get install vim
echo 192.168.99.2 : $1 >> /etc/ipsec.secrets
echo "syntax on" >> /root/.vimrc
cat <<EOF > /etc/strongswan.conf
# /etc/strongswan.conf - strongSwan configuration file

charon {
  load = random nonce aes sha1 sha2 curve25519 hmac stroke kernel-netlink socket-default updown
}
EOF

IP_ADDRESS=$(curl http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

cat <<EOF > /etc/ipsec.conf
# /etc/ipsec.conf - strongSwan IPsec configuration file

config setup

conn %default
	ikelifetime=60m
	keylife=20m
	rekeymargin=3m
	keyingtries=1
	keyexchange=ikev2
	authby=secret

conn rw
	left=$IP_ADDRESS
	leftsubnet=172.16.0.0/16
	leftfirewall=yes
	right=%any
	auto=add
EOF
