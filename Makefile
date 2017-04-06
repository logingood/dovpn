.PHONY: all plan apply vpnup destroy

IPSEC_KEY=$(shell terraform show|grep hex | cut -f 5 -d " ")

STRONGSWAN_CLIENT=$(shell which ipsec > /dev/null; echo $$?)

all: plan apply vpnup

plan: 
	@terraform plan

apply: 
	@terraform apply

vpnup:

ifeq ($(STRONGSWAN_CLIENT), 0)
	@echo "phone droplet : PSK \"${IPSEC_KEY}\"" > /etc/ipsec.secrets
	@sleep 120
	@service strongswan restart
else
	@echo "strongswan is not installed"
endif

destroy:
	@ipsec down client
	@terraform destroy
