# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
    end

  config.vm.define :clienteUbuntu do |clienteUbuntu|
    clienteUbuntu.vm.box = "bento/ubuntu-22.04"
    clienteUbuntu.vm.network :private_network, ip: "192.168.100.101"
    clienteUbuntu.vm.hostname = "clienteUbuntu"
    clienteUbuntu.vm.provision "shell", path: "./script.sh"
  end

  config.vm.define :servidorUbuntu do |servidorUbuntu|
    servidorUbuntu.vm.box = "bento/ubuntu-22.04"
    servidorUbuntu.vm.network :private_network, ip: "192.168.100.102"
    servidorUbuntu.vm.hostname = "servidorUbuntu"
    servidorUbuntu.vm.provision "shell", path: "./script2.sh"
  end

  config.vm.define :servidorHaproxy do |servidorHaproxy|
    servidorHaproxy.vm.box = "bento/ubuntu-22.04"
    servidorHaproxy.vm.network :private_network, ip: "192.168.100.100"
    servidorHaproxy.vm.hostname = "servidorHaproxy"
    servidorHaproxy.vm.provision "shell", path: "./script3.sh"
  end
 
end
