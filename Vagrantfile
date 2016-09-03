Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false
  config.vm.box = "terrywang/archlinux"
  config.vm.define "nomad1" do |nomad1|
    nomad1.vm.network "private_network", ip: "192.168.230.101"
    nomad1.vm.hostname = "nomad1"
  end

  config.vm.define "nomad2" do |nomad2|
    nomad2.vm.network "private_network", ip: "192.168.230.102"
    nomad2.vm.hostname = "nomad2"
  end

  config.vm.define "nomad3" do |nomad3|
    nomad3.vm.network "private_network", ip: "192.168.230.103"
    nomad3.vm.hostname = "nomad3"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/playbooks/nomad.yml"
    ansible.sudo = true
    ansible.extra_vars = {
        ansible_python_interpreter: "/usr/bin/python2",
    }
    ansible.groups = {
        "nomad" => ["nomad1", "nomad2", "nomad3"]
    }
  end

  config.vm.provision "shell", path: "scripts/vagrant_prov.sh"
end
# vim: ft=ruby
