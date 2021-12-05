Vagrant.configure("2") do |config|

    ## a imagem que vai ser usada para o SO é o ubuntu32
    config.vm.box = "hashicorp/bionic64" 
    ## configurando apenas uma máquina chamada web
    config.vm.define :web do |web_config|
        ## configurando uma rede e atribuindo um ip
        web_config.vm.network "private_network", ip: "192.168.50.10"
        # usar localhost em minha máquina
        #web_config.vm.network "forwarded_port", guest: 8080, host: 8081
        ## instalando o puppet
        web_config.vm.provision "shell", inline: "sudo apt-get update && sudo-apt-get install -y puppet"
    end
end