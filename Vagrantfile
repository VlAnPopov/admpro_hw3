# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

MACHINES = {
  :raid_script => {
        :box_name => "centos/8",
        :name => "raidstandscript",
        :ip_addr => '192.168.56.150',
        :memory => 1024,
        :cpus => 1,
        :script => "raid_script.sh",
        :disks => {
		    :sata1 => {
		    	:dfile => './sata1_1.vdi',
		    	:size => 1000,
		    	:port => 1
		    },
		    :sata2 => {
                :dfile => './sata1_2.vdi',
                :size => 1000, # Megabytes
			    :port => 2
		    },
            :sata3 => {
                :dfile => './sata1_3.vdi',
                :size => 1000,
                :port => 3
            },
            :sata4 => {
                :dfile => './sata1_4.vdi',
                :size => 1000, # Megabytes
                :port => 4
            },
            :sata5 => {
                :dfile => './sata1_5.vdi',
                :size => 1000, # Megabytes
                :port => 5
            },
            :sata6 => {
                :dfile => './sata1_6.vdi',
                :size => 1000, # Megabytes
                :port => 6
            }
	    }
  },
  :raid_ansible => {
    :box_name => "centos/8",
    :name => "raidstandansible",
    :ip_addr => '192.168.56.151',
    :memory => 1024,
    :cpus => 1,
    :script => "raid_ansible.sh",
    :ansible => "raid.yml",
    :disks => {
        :sata1 => {
            :dfile => './sata2_1.vdi',
            :size => 1000,
            :port => 1
        },
        :sata2 => {
            :dfile => './sata2_2.vdi',
            :size => 1000, # Megabytes
            :port => 2
        },
        :sata3 => {
            :dfile => './sata2_3.vdi',
            :size => 1000,
            :port => 3
        },
        :sata4 => {
            :dfile => './sata2_4.vdi',
            :size => 1000, # Megabytes
            :port => 4
        }
    }
},
}

Vagrant.configure("2") do |config|

    MACHINES.each do |boxname, boxconfig|
  
        config.vm.define boxname do |box|
  
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxconfig[:name] 
            box.vm.network "private_network", ip: boxconfig[:ip_addr]
            # Отключаем общую папку, поскольку без манипуляций с guest additions в используемом боксе вагрант не может создать расшаренную
            # папку и делает простую синхронизацию - а все дополнительные диски дублировать в ВМ мне не надо.
            box.vm.synced_folder ".", "/vagrant", disabled: true
  
            box.vm.provider :virtualbox do |vb|
                vb.memory = boxconfig[:memory]
                vb.cpus = boxconfig[:cpus]
                needsController = false
                boxconfig[:disks].each do |dname, dconf|
                    unless File.exist?(dconf[:dfile])
                        vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                        needsController =  true
                    end
                end
                if needsController == true
                    vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                    boxconfig[:disks].each do |dname, dconf|
                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                    end
                end
            end
            box.vm.provision "shell", path: boxconfig[:script]
            if boxconfig.key?(:ansible) 
                box.vm.provision "ansible" do |ansible|
                    ansible.playbook = boxconfig[:ansible]
                end
            end
        end
    end
  end