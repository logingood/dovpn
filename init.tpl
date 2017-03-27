
#cloud-config

runcmd:
  - wget https://raw.githubusercontent.com/murat1985/do-vpn/master/init.sh -o /tmp/init.sh
  - chmod +x /tmp/init.sh
  - /tmp/init.sh ${secret_key} | dd of=/var/log/bootstrap.log
