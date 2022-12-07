Box = Struct.new(:hostname, :purpose, :address) do
  end
Vagrant.configure("2") do |config|
    config.vm.box = ["ubuntu/focal64", "centos/7"].sample
    config.vm.provider "virtualbox"
    config.ssh.password = "password"

    hostnames = ["ed", "lazlo"] # hostnames
    purposes = ["wordpress", "mysql"] # primary services
    ips = []
    2.times do
        ips << "192.168.220.#{rand(2..200)}"
    end

    # Creating Boxes with random names, IPs, and purposes (services)
    firstBox = Box.new(hostnames.sample, purposes.sample, ips.sample)
    hostnames.delete(firstBox.hostname)
    purposes.delete(firstBox.purpose)
    ips.delete(firstBox.address)

    secondBox = Box.new(hostnames.sample, purposes.sample, ips.sample)
    hostnames.delete(secondBox.hostname)
    purposes.delete(secondBox.purpose)
    ips.delete(secondBox.address)

    allBoxes = [firstBox, secondBox]

    /
    Config.vm.define => Define a purpose for the vm (ansible believes this is the hostname)
        box.vm.hostname => hostname
        box.vm.network => private network, we give it the random ip now
    /
    # The first box
    config.vm.define firstBox.purpose do |box1|
      box1.vm.hostname = firstBox.hostname
      box1.vm.network "private_network", ip: firstBox.address
      
    end
  
    # The second box
    config.vm.box = ["ubuntu/focal64", "centos/7"].sample

    config.vm.define secondBox.purpose do |box2|
      box2.vm.hostname = secondBox.hostname
      box2.vm.network "private_network", ip: secondBox.address
    end

    # Its ansibling time
    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "playbook.yml"
        ansible.host_vars = 
        { "wordpress" => 
            {
                "mysql_host" => (allBoxes.find{|o| o[:purpose] == "mysql" })[:address]
            },
        }
    end
end