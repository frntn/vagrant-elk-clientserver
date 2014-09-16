    # -*- mode: ruby -*-lab
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.forward_agent = true

  config.vm.define "elkserver" do |elkserver|
    elkserver.vm.box = "frntn/trusty64-elk"
    elkserver.vm.network "private_network", ip: "192.168.34.150"
    elkserver.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end

  config.vm.define "elkclient" do |elkclient|
    elkclient.vm.box = "frntn/trusty64-wordpress"
    elkclient.vm.network "private_network", ip: "192.168.34.151"
    elkclient.vm.provision "shell", path: "elkclient-provision.sh"
  end

end
