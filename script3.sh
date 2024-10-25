#!/bin/bash
echo "Actualizar Paquetes"
sudo apt-get update

echo "Instalando Agente Consul"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install consul

echo "Instalando un servidor NodeJS"
sudo apt install -y nodejs
sudo apt install -y aptitude
sudo aptitude install -y npm

sudo apt install -y git

echo "instalar Haproxy"
sudo apt-get install -y haproxy
sudo chown -R vagrant:vagrant /home/vagrant/consul_data
#git clone https://github.com/omondragon/consulService
#cd consulService/app

# Unir al clúster de Consul (máquina consul1)       
consul agent -node=servidorHaproxy -bind=192.168.100.100 -client=0.0.0.0 -data-dir=/home/vagrant/consul_data -join=192.168.100.101 &

# Configurar HAProxy para balancear el tráfico       
sudo bash -c 'cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    # Default SSL material locations
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private
    # Default ciphers to use on SSL-enabled listening sockets.
    # For more information, see ciphers(1SSL). This list is from:
    #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
    # An alternative list with additional directives can be obtained from
    #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
    ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
    ssl-default-bind-options no-sslv3
defaults
    log global
    mode    http
    option  httplog
    option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http
frontend http-in
    bind *:80
    default_backend web-backend


resolvers consul
    nameserver consul 192.168.100.101:8600
    accepted_payload_size 8192
    hold valid 5s
backend web-backend
   balance roundrobin
   server-template web-backend 1-10 _mymicroservice._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check
   stats enable
   stats auth admin:admin
   stats uri /haproxy?stats
#   server clienteUbuntu 192.168.100.101:5000 check
#   server servidorUbuntu  192.168.100.102:5000 check

#frontend http
#  bind *:80
#  default_backend web-backend
EOF'

# reniciar HAproxy
  sudo systemctl restart haproxy