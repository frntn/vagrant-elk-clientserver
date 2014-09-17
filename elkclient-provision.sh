#!/bin/bash

elkserverip="192.168.34.150"
lumberjackport="5000"
collectdport="25826"

# VAGRANT'S INSECURE PRIVATE KEY TO ACCESS ELKSERVER
mkdir -p ~/.ssh 
chmod 700 ~/.ssh 
wget -q https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant -O ~/.ssh/id_dsa
chmod 400 ~/.ssh/id_dsa

# LOGSTASH-FOWARDER (ENCRYPTED)
# =============================

## INSTALL 
echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
wget -q -O- http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
apt-get update
apt-get -y install logstash-forwarder

## INIT SCRIPT
wget -q https://raw.github.com/elasticsearch/logstash-forwarder/master/logstash-forwarder.init -O /etc/init.d/logstash-forwarder
chmod +x /etc/init.d/logstash-forwarder
update-rc.d logstash-forwarder defaults

## CERTIFICATE FROM SERVER
mkdir -p /etc/pki/tls/certs
scp -o StrictHostKeyChecking=no vagrant@$elkserverip:/etc/pki/tls/certs/logstash-forwarder.crt /etc/pki/tls/certs/
rm -f ~/.ssh/id_dsa

## LUMBERJACK FORWARD (ENCRYPTED)
cat <<EOCONF > /etc/logstash-forwarder
{
  "network": {
    "servers": [ "$elkserverip:$lumberjackport" ],
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

## COLLECTD OUPUT (ENCRYPTED)
## Password: Using sha1 of logstash-forwarder certificate. 
## Easier for testing purpose (use already shared element to create a shared secret). 
## Do NOT use this trick in a production env

apt-get install -y collectd collectd-utils
cat <<EOF > /etc/collectd/collectd.conf.d/network.conf
LoadPlugin network
<Plugin network>
    <Server "$elkserverip" "$collectdport">
        SecurityLevel "Encrypt"
        Username "kibana"
        Password "$(sha1sum /etc/pki/tls/certs/logstash-forwarder.crt | awk '{print $1}')"
    </Server>
</Plugin>
EOF

# RESTART SERVICES
service logstash-forwarder restart
service collectd restart


