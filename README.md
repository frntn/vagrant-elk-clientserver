
> MAJOR SECURITY UPDATE 09/27/2014 : Fixed bash version after the [shellshocker.net](https://shellshocker.net/) nuke

# Client-Server ELK demo

* Boxes : [vagrantcloud/frntn](http://www.vagrantcloud.com/frntn)
* Issues : [github/frntn](https://github.com/frntn/vagrant-elk-clientserver/issues)
* Feedbacks : [twitter/frntn](http://www.twitter.com/frntn)

The purpose of this project is to give a quick & easy to use environment to
play around with the now famous ElasticSearch - Logstash - Kibana stack
a.k.a. ELK stack.

## Quick Overview

The project uses vagrant, and the preconfigured boxes are for virtualbox for 
now.

It builds up 2 virtual machines : 

### elkserver

* The [frntn/trusty64-elk](https://vagrantcloud.com/frntn/boxes/trusty64-elk) 
source box has a full ELK stack.
* VM is provisioned at start up to add `collectd listener` (with encryption)
* VM has host-only IP address `192.168.34.150`
* `Kibana` is binded on port 80 through `nginx`
* `ElasticSearch` is binded on port 9200
* `lumberjack listener` is binded on port 5000 through `logstash` 
[input](http://logstash.net/docs/latest/inputs/lumberjack)
* `collectd listener` is binded on port 25826 through `logstash`
[input](http://logstash.net/docs/latest/inputs/collectd)

### elkclient

* The [frntn/trusty64-wordpress](https://vagrantcloud.com/frntn/boxes/trusty64-wordpress) 
contains a ready to use WORDPRESS server
* VM is provisioned at start up to install and configure `logstash-forwarder`
and `collectd`
* VM has host-only IP address `192.168.34.151`
* `Wordpress` is binded on port 80 through `nginx`
* `Logstash-forwarder` is configured to send auth and syslog events to 
elkserver. Easily extendable to wordpress logs and more...
* `collectd` is configured to send system metrics to elkserver.

## Getting Started

Pre-requisites : [Vagrant](http://www.vagrantup.com/) and 
[Virtualbox](https://www.virtualbox.org/) are installed on your host.

Clone the repo

```shell
$ git clone https://github.com/frntn/vagrant-elk-clientserver.git frntn-elk
$ cd frntn-elk
```

Start the VMs 

```shell
$ vagrant up
```

Boxes are now up, you should be able to access them with your browser :

* Kibana : http://192.168.34.150/ ( the IHM you are waiting for ;) )
* Wordpress : http://192.168.34.151/

If not, you might need some extra configuration for it to work in your own 
environment (port forwarding, ...). I suggest you read the 
[vagrant documentation](http://docs.vagrantup.com/v2/).

Feel free to contact me (links at the beginning of this file).

## Slightly more advanced usage

Starting VM one by one

```shell
$ vagrant up elkserver
$ vagrant up elkclient
```

> Note : `elkclient` provisioning grab certificate from server to send logs 
> through an encrypted connection. So if you start this vm from "not created" 
> state or force "provision" of an existing one `elkserver` should be up too.

Connecting via SSH

```shell
$ vagrant ssh elkserver
$ vagrant ssh elkclient
```

## TODO

Add extra configuration to Logstash-fowarder to enable wordpress application logging  

----
*Hope you'll like this project as much as I add fun creating it :)*
