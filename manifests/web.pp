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

# criando o banco de dados
exec{"musicjungle":
  command => "mysqladmin -uroot create musicjungle",
  unless => "mysql -u root musicjungle", # se o banco existe, não roda esse comando
  path => '/usr/bin',
  require => Service["mysql"]
}

# criando uma senha para o banco de dados
exec { "mysql-password" :
  command => "mysql -uroot -e \"GRANT ALL PRIVILEGES ON * TO 'musicjungle'@'%' IDENTIFIED BY 'minha-senha';\" musicjungle",
  unless  => "mysql -umusicjungle -pminha-senha musicjungle",
  path => "/usr/bin",
  require => Exec["musicjungle"]
}

# colocando que o ambiente será de produção (na última linha)
fine_line{
  "production":
    file => "/etc/default/tomcat8",
    line => "JAVA_OPTS=\"\$JAVA_OPTS -Dbr.com.caelum.vraptor.environment=production\""
}

define fine_line($file, $line){
  exec{"/bin/echo '${line}' >> '${file}'":
        unless => "/bin/grep -qFx '${line}' '${file}'" # se já houver essa linha escrita, não coloca de novo
  }
}


# colocando a aplicação na pasta webapps do tomcat para subir para produção 
file {"/var/lib/tomcat8/webapps/vraptor-musicjungle.war":
  # copiando esse  arquivo .war para a pasta do tomcat
  source => "/vagrant/manifests/vraptor-musicjungle.war",
  owner => tomcat8,
  group => tomcat8,
  mode => '0644', #modo de acesso
  require => Package["tomcat8"], 
  notify => Service["tomcat8"] # notificando o tomcat para ele restartar
}
