#!/bin/bash
# to check logs of build look here
# /var/log/cloud-init.log and
# /var/log/cloud-init-output.log
echo "RHEL OS"

sudo yum update -y

sudo yum install curl -y

sudo yum install wget -y

sudo yum install ca-certificates -y

sudo yum install stress-ng -y

sudo yum install apache2 -y

sudo service apache2 restart

echo "<h3>Web Server: ${HOSTNAME}</h3>" | sudo tee /var/www/html/index.html
