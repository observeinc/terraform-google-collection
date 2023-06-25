#!/bin/bash
# to check logs of build look here
# /var/log/cloud-init.log and
# /var/log/cloud-init-output.log
    
echo "UBUNTU OS"

### Updates and installs
sudo apt-get update -y

##### HTTP
sudo apt-get install wget curl -y
sudo apt install ca-certificates -y

## For mounting storage bucket as drive
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`

echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update

sudo apt-get install gcsfuse

# need to execute as user or flames
sudo -u ubuntu bash -c 'mkdir /home/ubuntu/bucket'

# sudo -u ubuntu bash -c 'mkdir /home/ubuntu/flask'

# mount bucket as directory in ubuntu home
sudo -u ubuntu bash -c 'gcsfuse --implicit-dirs ${BUCKET_NAME} /home/ubuntu/bucket'

# sudo -u ubuntu bash -c 'cp -a /home/ubuntu/bucket/flask/. /home/ubuntu/flask/'

# sudo chmod 777 /home/ubuntu/flask/some.sh

# python install
sudo apt install python3-pip -y

${append_script}
# pip install flask

# pip install google-cloud-bigquery

# pip install mysql-connector-python

# pip install psycopg2-binary

# # define service for flask app
# sudo tee /etc/systemd/system/flaskapi.service <<EOF
# [Unit]
# Description=Flask api application
# After=network.target

# [Service]
# Environment="FLASK_APP=main.py"
# User=ubuntu
# WorkingDirectory=/home/ubuntu/flask
# ExecStart=flask --app main.py run --host 0.0.0.0 -p 8080
# Restart=always

# [Install]
# WantedBy=multi-user.target
# EOF

# # start service
# sudo systemctl daemon-reload
# sudo service flaskapi start

# # https://wiki.ubuntu.com/Kernel/Reference/stress-ng
# sudo apt-get install stress-ng -y

# # create apache server
# sudo apt-get -y install apache2

# sudo service apache2 restart

# # simple html file for apache
# sudo tee /var/www/html/index.html <<EOF
# <h3>Web Server: $${HOSTNAME}</h3>
# EOF