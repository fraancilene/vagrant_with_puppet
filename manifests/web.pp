# executando os comandos

# atualizando o SO
exec {
  "apt-update":
    command => "/usr/bin/apt-get update"
}

# instalando os pacotes java, tomcat, mysql
package {["openjdk-8-jre", "tomcat8", "mysql-server"]:
    ensure => installed, #verificando se foram instalados
    require => Exec["apt-update"] # verificando se o comando de update foi rodado
}

#instalando unzip - só para teste
package {'unzip' : 
  ensure => installed, #verificando se foi instalado
  require => Exec["apt-update"] # verificando se o comando de update foi rodado
}

# DEPLOYANDO UMA WEBAPP
# reiniciando o tomcat
service{ "tomcat8":
  ensure => running, # verificando se está ligado
  enable => true,
  hasrestart =>true, # reiniciando o tomcat
  require => Package["tomcat8"] # informando que depende do pacote tomcat8
}

# verificando se o mysql está instalado e rodando
service {"mysql":
  ensure => running,
  enable => true,
  hasstatus => true,
  hasrestart =>true,
  require => Package["mysql-server"] # informando que depende do pacote mysql-server
}

exec{"musicjungle":
  command => "mysqladmin -uroot create musicjungle",
  path => "/usr/bin",
  require => Service["mysql"]
}

file {"/var/lib/tomcat8/webapps/vraptor-musicjungle.war":
  # copiando esse  arquivo .war para a pasta do tomcat
  source => "/vagrant/manifests/vraptor-musicjungle.war",
  owner => tomcat8,
  group => tomcat8,
  mode => '0644', #modo de acesso
  require => Package["tomcat8"], 
  notify => Service["tomcat8"] # notificando o tomcat para ele restartar
}
