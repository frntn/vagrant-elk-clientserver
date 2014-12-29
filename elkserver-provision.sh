#!/bin/bash

# COLLECTD INPUT (ENCRYPTED)
# Password: Using sha1 of logstash-forwarder certificate. 
# Easier for testing purpose (use already shared element to create a shared secret). 
# Do NOT use this trick in a production env
# ====================

auth="/etc/logstash/collectd.authfile"
conf="/etc/logstash/conf.d/02-collectd-input.conf"
collectdport="25826"

cat <<EOF > "$auth"
kibana: $(sha1sum /etc/pki/tls/certs/logstash-forwarder.crt | awk '{print $1}')
EOF

cat <<EOF > "$conf"
input {
  collectd {
    port => $collectdport
    type => "metrics"
    security_level => "Encrypt"
    authfile => "/etc/logstash/collectd.authfile"
  }
}
EOF

mv /tmp/*.jar "/usr/lib/jvm/java-7-oracle/jre/lib/security/"
mv /tmp/nginx-default "/etc/nginx/sites-available/default"

service logstash restart
service nginx restart
