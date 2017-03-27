variable "do_token" {}
variable "ssh_key" {}
variable "domain_name" {}
variable "droplet_name" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "do_sshkey" {
  name       = "Digital Ocean"
  public_key = "${file("${var.ssh_key}")}"
}


# Create a web server
resource "digitalocean_droplet" "mydroplet" {
  image    = "11.0 x64 ZFS"
  name     = "${var.droplet_name}"
  region   = "blr1"
  size     = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.do_sshkey.id}"]
  user_data = <<EOF
#cloud-config

runcmd:
  - pkg upgrade
  - pkg clean
  - kldload zfs
  - dd if=/dev/zero of=/usr/local/dockerfs bs=1024k count=8192
  - zpool create -f zroot /usr/local/dockerfs
  - zfs create -o mountpoint=/usr/docker zroot/docker  
  - pkg install docker-freebsd ca_root_nss
  - sysrc -f /etc/rc.conf docker_enable="YES"
  - service docker start
EOF
}

resource "digitalocean_domain" "my-domain" {
  name       = "${var.domain_name}"
  ip_address = "${digitalocean_droplet.mydroplet.ipv4_address}"
}

resource "digitalocean_record" "mydroplet" {
  domain = "${digitalocean_domain.my-domain.name}"
  type   = "A"
  name   = "${var.droplet_name}"
  value  = "${digitalocean_droplet.mydroplet.ipv4_address}"
}
