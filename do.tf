variable "do_token" {}
variable "do_region" {}
variable "ssh_key" {}
variable "droplet_name" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "do_sshkey" {
  name       = "Digital Ocean"
  public_key = "${file("${var.ssh_key}")}"
}

resource "random_id" "ipsec_key" {
  byte_length = 32
}

data "template_file" "init" {
  template = "${file("init.tpl")}"
  vars {
    ipsec_ip   = "0.0.0.0"
    secret_key = "${random_id.ipsec_key.hex}"
  }
}

# Create a web server
resource "digitalocean_droplet" "mydroplet" {
  image    = "ubuntu-16-04-x64"
  name     = "${var.droplet_name}"
  region   = "${var.do_region}"
  size     = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.do_sshkey.id}"]
  ipv6 = true
  user_data = "${data.template_file.init.rendered}"
}
