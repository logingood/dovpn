# Description

This repository allows to create [Digital Ocean](https://m.do.co/c/eb230fc23336) 512m droplet running Ubuntu 16.04, and then install 
[Strongswan](strongswan.org)

Strongswan is configured to accept remote-access IPSEC VPN IKEv2 connections, with the following transform sets:

* IKE phase 1:
- `aes256-sha256-modp1024` IOS 9+ for Apple iPad, iPhone and etc
- `aes256-sha1-modp1024` Win 7
- `3des-sha1-modp1024` OS X

* IKE phase 2:
- `aes256-sha256` IOS
- `aes256-sha1` Win 7
- `3des-sha1` OS X

As authentication is used PSK (shared-key). PSK is being generated using Terraform resource `random_id"`, e.g.

```
resource "random_id" "ipsec_key" {
  byte_length = 32
}
```

That ensures that PSK will be unique every time and cryptographically random. 

Strongswan configuration is defined within https://github.com/murat1985/dovpn/blob/master/init.sh script.

# Install
As pre-requesits you need the following:

* Have [Terraform](https://www.terraform.io/downloads.html) installed, OS X/Linux/Windows/FreeBSD are supported
* Clone this repository:
```
git clone https://github.com/murat1985/dovpn
```
* Generate [Digital Ocean](https://m.do.co/c/eb230fc23336) Token
* Create environment variables:

```
export TF_VAR_do_token=digital_ocean_token
export TF_VAR_ssh_key=~/.ssh/id_rsa.pub
export TF_VAR_domain_name=mydomain.invalid
export TF_VAR_droplet_name=mydroplet
```

We assume that you have a domain name, and it is deligated to [Digital Ocean nameserver](https://www.digitalocean.com/community/tutorials/how-to-point-to-digitalocean-nameservers-from-common-domain-registrars)
otherwise you can slightly modify TF template. Having domain is better as you can refer your VPN server by domain name
without changing IP address.

# Use
Change directory to cloned repository:
```
cd dovpn 
```

Run terraform commands, check that output is correct and expected:

```
make plan
```

Create a droplet:

```
make apply
```

Get PSK key from the output, we are using hex format, so you need to grep hex

```
terraform show
```

# TODO

- Add Xauth support
- Extract some variables to environment
- Dockerise ? 

# PS
You probably want to fork this repository to make required alterations, also `init.tpl` script
is downloading [init.sh](https://raw.githubusercontent.com/murat1985/dovpn/master/init.sh) from this repository
probably you want to change it to yours. The script url will be exctracted in future.
