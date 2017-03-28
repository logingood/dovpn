
#cloud-config

runcmd:
  - curl https://raw.githubusercontent.com/murat1985/dovpn/master/init.sh -o /tmp/init.sh
  - chmod +x /tmp/init.sh
  - /tmp/init.sh ${secret_key} | dd of=/var/log/bootstrap.log
