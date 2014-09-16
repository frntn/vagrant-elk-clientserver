#!/bin/bash

# INSTALL
echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
wget -q -O- http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
apt-get update
apt-get -y install logstash-forwarder

# INIT SCRIPT
wget -q https://raw.github.com/elasticsearch/logstash-forwarder/master/logstash-forwarder.init -O /etc/init.d/logstash-forwarder
chmod +x /etc/init.d/logstash-forwarder
update-rc.d logstash-forwarder defaults

# VAGRANT'S INSECURE PRIVATE KEY TO ACCESS ELKSERVER
mkdir -p ~/.ssh 
chmod 700 ~/.ssh 
wget -q https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant -O ~/.ssh/id_dsa
chmod 400 ~/.ssh/id_dsa

# CERTIFICATE FROM SERVER
mkdir -p /etc/pki/tls/certs
scp -o StrictHostKeyChecking=no vagrant@192.168.34.150:/etc/pki/tls/certs/logstash-forwarder.crt /etc/pki/tls/certs/

# BASE CONFIGURATION
cat <<EOCONF > /etc/logstash-forwarder
{
  "network": {
    "servers": [ "192.168.34.150:5000" ],
    "timeout": 15,
    "ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"
  },
  "files": [
    {
      "paths": [
        "/var/log/syslog",
        "/var/log/auth.log"
       ],
      "fields": { "type": "syslog" }
    }
   ]
}
EOCONF

# RESTART SERVICE
service logstash-forwarder restart


