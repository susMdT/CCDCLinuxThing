=begin
    Each Machine will have
    [STRING] Hostname => name of host. This is not relevant to ansible
    [SERVICE] PrimaryService => Primary service(s) of this host, 0-2.
    [SERVICE] OtherService => Services that are more for attack surface than actually being scored OR are the dependencies for the primary services, 1-2
    [STRING] Address => Ip address
    [STRING] OS => OS (so vagrant can pull box)
    [STRING] simpleOS => For information and ansible parsing
    [STRING] simpleService => For informational
=end
Box = Struct.new(:hostname, :primaryService, :os, :address, :simpleOS, :simpleService) 

=begin
    [STRING] name => service name 
    [ARRAY][STRING] dependencies => array of service names that it needs. 
=end
Service = Struct.new(:name, :dependencies) 

=begin
    [STRING] dependencyName => service name of the dependency
    [STRING] boxName => hostname of who is filling this dependency
    [STRING] boxAddress => address of who is filling this dependency
    [BOOL] isMet => status of this dependency; is it met already
=end
Dependencies = Struct.new(:dependencyName, :boxName, :boxAddress, :isMet) 
Vagrant.configure("2") do |config|

    config.vm.provider 'virtualbox' do |vb|
        vb.memory = 2048
        vb.cpus = 2
    end

    dependencyQuota = [] # Array of Dependencies

    # Potential Box properties
    hostnames = ["ed", "lazlo", "dexter", "toonami"] # hostnames
    services = [
        Service.new("wordpress", ["sql"]),
        Service.new("sql", []),
        Service.new("vsftpd", []),
        Service.new("flask", []),
        Service.new("samba", [])
    ]

    os = ["ubuntu/focal64", "centos/7", "generic/alpine312", "generic/debian10"]
    ips = []
    4.times do
        ip_address = "192.168.220.#{rand(1..200)}"
        # Check if the generated IP address is already in the array
        while ips.include?(ip_address)
          ip_address = "192.168.220.#{rand(1..200)}"
        end
        ips << ip_address
      end


    # Creating Boxes with random names, IPs, and purposes (services)
    firstBox = Box.new(hostnames.sample, services.sample, os.sample, ips.sample)
    os.delete(firstBox.os) # debug purposes; try all 3 os
    hostnames.delete(firstBox.hostname)
    ips.delete(firstBox.address)
    if (firstBox.primaryService.dependencies.length() > 0) # Adding to the list of unmet dependencies
        firstBox.primaryService.dependencies.each do |n|
            dependencyQuota.push(Dependencies.new(n, "", "", false))
        end
    end

    if (!(dependencyQuota.find{|o| o[:isMet] == false }).nil?)
        unmetDependency = (dependencyQuota.select{|o| o[:isMet] == false }).sample # From the dependencyQuota, find all Dependencies objects where isMet == false, and pick a random one
        secondBox = Box.new(hostnames.sample, (services.find{|o| o[:name] == unmetDependency.dependencyName}), os.sample, ips.sample)
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].isMet = true
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].boxName = secondBox.hostname
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].boxAddress = secondBox.address
    else
        secondBox = Box.new(hostnames.sample, services.sample, os.sample, ips.sample)
    end
    os.delete(secondBox.os) # debug purposes; try all 3 os
    hostnames.delete(secondBox.hostname)
    ips.delete(secondBox.address)
    if (secondBox.primaryService.dependencies.length() > 0) # Adding to the list of unmet dependencies
        secondBox.primaryService.dependencies.each do |n|
            dependencyQuota.push(Dependencies.new(n, "", "", false))
        end
    end

    if (!(dependencyQuota.find{|o| o[:isMet] == false }).nil?)
        unmetDependency = (dependencyQuota.select{|o| o[:isMet] == false }).sample # From the dependencyQuota, find all Dependencies objects where isMet == false, and pick a random one
        thirdBox = Box.new(hostnames.sample, (services.find{|o| o[:name] == unmetDependency.dependencyName}), os.sample, ips.sample)
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].isMet = true
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].boxName = thirdBox.hostname
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].boxAddress = thirdBox.address
    else
        thirdBox = Box.new(hostnames.sample, services.sample, os.sample, ips.sample)
    end
    os.delete(thirdBox.os) # debug purposes; try all 3 os
    hostnames.delete(thirdBox.hostname)
    ips.delete(thirdBox.address)
    if (thirdBox.primaryService.dependencies.length() > 0) # Adding to the list of unmet dependencies
        thirdBox.primaryService.dependencies.each do |n|
            dependencyQuota.push(Dependencies.new(n, "", "", false))
        end
    end

    if (!(dependencyQuota.find{|o| o[:isMet] == false }).nil?)
        unmetDependency = (dependencyQuota.select{|o| o[:isMet] == false }).sample
        fourthBox = Box.new(hostnames.sample, (services.find{|o| o[:name] == unmetDependency.dependencyName}), os.sample, ips.sample)
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].isMet = true
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].boxName = fourthBox.hostname
        dependencyQuota[dependencyQuota.find_index(unmetDependency)].boxAddress = fourthBox.address
    else
        fourthBox = Box.new(hostnames.sample, (services.select{|o| o[:dependencies].length() == 0}).sample, os.sample, ips.sample) #The last box cannot host a service with dependencies because then its fucked
    end
    os.delete(fourthBox.os) # debug purposes; try all 3 os
    hostnames.delete(fourthBox.hostname)
    ips.delete(fourthBox.address)

    allBoxes = [firstBox, secondBox, thirdBox, fourthBox]

    # Do some stuff on the host before (and only before) the first vagrant up
    # Also provision ansible if all hosts are up'd

    # Now we must change each box OS so ansible takes it better and it prints cooler
    allBoxes.each do |box|
        case box.os
            when "ubuntu/focal64"
                box.simpleOS = "Ubuntu 20.04"
            when "centos/7"
                box.simpleOS = "Centos 7"
            when "generic/alpine312"
                box.simpleOS = "Alpine 3.12"
            when "generic/debian10"
                box.simpleOS = "Debian 10"
        end
    # Now we must change each box service name so printing is vague
        case box.primaryService.name
            when "wordpress"
                box.simpleService = "http"
            when "vsftpd"
                box.simpleService = "ftp"
            when "sql"
                box.simpleService = "sql"
            when "flask"
                box.simpleService = "http"
            when "samba"
                box.simpleService = "smb"
        end
    end
    config.trigger.before :up do |trigger|
        trigger.ruby do
            # Printing informational files
            generalInfoString = sprintf("+------------+----------------+\n")
            row_format = "| %{hostname} | %{service} |\n"
            generalInfoString +=  row_format % {hostname: "Hostname".center(10), service: "Scored Service".center(14)}
            generalInfoString += sprintf("+------------+----------------+\n")
            allBoxes.each do |box|
                generalInfoString += row_format % {hostname: box.hostname.center(10),service: box.simpleService.center(14)}
            end
            generalInfoString += sprintf("+------------+----------------+\n")
            File.open("general.txt", "w") do |file|
                file.write(generalInfoString)
            end

            adminTopologyString = sprintf("+------------+--------------+------------------+----------------+\n")
            row_format = "| %{hostname} | %{os} | %{ip} | %{service} |\n"
            adminTopologyString += row_format % {hostname: "Hostname".center(10), os: "OS".center(12), ip: "IP Address".center(16), service: "Scored Service".center(14)}
            adminTopologyString += sprintf("+------------+--------------+------------------+----------------+\n")
            allBoxes.each do |box|
                adminTopologyString += row_format % {hostname: box.hostname.center(10), os: box.simpleOS.center(12), ip: box.address.center(16), service: box.primaryService.name.center(14)}
            end
            adminTopologyString += sprintf("+------------+--------------+------------------+----------------+\n")
            File.open("admin.txt", "w") do |file|
                file.write(adminTopologyString)
            end
        end
    end

    config.vm.define allBoxes[0].hostname do |box1|
        box1.vm.box = allBoxes[0].os
        box1.vm.hostname = allBoxes[0].hostname
        box1.vm.network "private_network", ip: allBoxes[0].address
        box1.vm.disk :disk, size: "20GB", primary: true
        config.vm.provision :hosts do |provisioner|
            provisioner.add_host allBoxes[0].address, [allBoxes[0].hostname]
            provisioner.add_host allBoxes[1].address, [allBoxes[1].hostname]
            provisioner.add_host allBoxes[2].address, [allBoxes[2].hostname]
            provisioner.add_host allBoxes[3].address, [allBoxes[3].hostname]
        end
        if box1.vm.box == "generic/alpine312" # Alpine dont got python, so ansible cries
            box1.vm.provision "shell", reset: true, inline:
            '''
                apk add python3 py3-pip
            '''
        end
    end

    config.vm.define allBoxes[1].hostname do |box2|
        box2.vm.box = allBoxes[1].os
        box2.vm.hostname = allBoxes[1].hostname
        box2.vm.network "private_network", ip: allBoxes[1].address
        box2.vm.disk :disk, size: "20GB", primary: true
        config.vm.provision :hosts do |provisioner|
            provisioner.add_host allBoxes[0].address, [allBoxes[0].hostname]
            provisioner.add_host allBoxes[1].address, [allBoxes[1].hostname]
            provisioner.add_host allBoxes[2].address, [allBoxes[2].hostname]
            provisioner.add_host allBoxes[3].address, [allBoxes[3].hostname]
        end
        if box2.vm.box == "generic/alpine312" # Alpine dont got python, so ansible cries
            box2.vm.provision "shell", reset: true, inline:
            '''
                apk add python3 py3-pip
            '''
        end
    end

    config.vm.define allBoxes[2].hostname do |box3|
        box3.vm.box = allBoxes[2].os
        box3.vm.hostname = allBoxes[2].hostname
        box3.vm.network "private_network", ip: allBoxes[2].address
        box3.vm.disk :disk, size: "20GB", primary: true
        config.vm.provision :hosts do |provisioner|
            provisioner.add_host allBoxes[0].address, [allBoxes[0].hostname]
            provisioner.add_host allBoxes[1].address, [allBoxes[1].hostname]
            provisioner.add_host allBoxes[2].address, [allBoxes[2].hostname]
            provisioner.add_host allBoxes[3].address, [allBoxes[3].hostname]
        end
        if box3.vm.box == "generic/alpine312" # Alpine dont got python, so ansible cries
            box3.vm.provision "shell", reset: true, inline:
            '''
                apk add python3 py3-pip
            '''
        end
    end

    config.vm.define allBoxes[3].hostname do |box4|
        box4.vm.box = allBoxes[3].os
        box4.vm.hostname = allBoxes[3].hostname
        box4.vm.network "private_network", ip: allBoxes[3].address
        box4.vm.disk :disk, size: "20GB", primary: true
        config.vm.provision :hosts do |provisioner|
            provisioner.add_host allBoxes[0].address, [allBoxes[0].hostname]
            provisioner.add_host allBoxes[1].address, [allBoxes[1].hostname]
            provisioner.add_host allBoxes[2].address, [allBoxes[2].hostname]
            provisioner.add_host allBoxes[3].address, [allBoxes[3].hostname]
        end
        if box4.vm.box == "generic/alpine312" # Alpine dont got python, so ansible cries
            box4.vm.provision "shell", reset: true, inline:
            '''
                apk add python3 py3-pip
            '''
        end
    end

    config.vm.provision "ansible" do |ansible| # Despite normal thinking, this triggers BEFORE the main book. This is intended to just fill out inventory and will run an empty b ook
        # Its ansibling time
        #Hostname
        #Host address
        #Operating System
        #Primary Service name
        #Ip address & Hostname of dependency
        ansible.playbook = "emptybook.yml"
        ansible.groups = 
        {
            "wordpress_hosts" => (allBoxes.select{|o| o.primaryService.name == "wordpress"}.map{ |machine| machine[:hostname] }),
            "sql_hosts" => (allBoxes.select{|o| o.primaryService.name == "sql"}.map{ |machine| machine[:hostname]}),
            "vsftpd_hosts" => (allBoxes.select{|o| o.primaryService.name == "vsftpd"}.map{ |machine| machine[:hostname]}),
            "flask_hosts" => (allBoxes.select{|o| o.primaryService.name == "flask"}.map{ |machine| machine[:hostname]}),
            "samba_hosts" => (allBoxes.select{|o| o.primaryService.name == "samba"}.map{ |machine| machine[:hostname]})
        }
    end
    
    # Allow password login
    config.vm.provision "shell", inline: <<-SHELL
        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
        sed -i 's/.PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config    
        echo root:vagrant | chpasswd
        service sshd restart
    SHELL
end

