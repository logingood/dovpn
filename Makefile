.PHONY: all plan apply vpnup destroy

IPSEC_KEY=$(shell terraform show|grep hex | cut -f 5 -d " ")


all: plan apply vpnup

plan: 
	terraform plan

apply: 
	terraform apply

vpnup:
	echo "phone droplet : PSK \"${IPSEC_KEY}\"" > /etc/ipsec.secrets
	service strongswan restart	

destroy:
	ipsec down client
	terraform destroy
