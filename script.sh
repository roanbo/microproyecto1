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
sudo apt install -y nodejs npm 
npm install consul
npm install express
sudo apt install -y git


cat <<EOF > server.js
const Consul = require('consul'); 
const express = require('express');

const SERVICE_NAME = 'mymicroservice';
const SERVICE_ID = 'm' + process.argv[2];
const SCHEME = 'http';
const HOST = '192.168.100.101'; // Cambia esto según sea necesario
const PORT = process.argv[2] * 1;
const PID = process.pid;

/* Inicialización del servidor */
const app = express();
const consul = new Consul();

app.get('/health', function (req, res) {
   console.log('Health check!');
   res.end("Ok.");
});

app.get('/', (req, res) => {
   console.log('GET /', Date.now());
   const htmlResponse = \`
      <html>
         <head>
            <title>Respuesta</title>
         </head>
         <body>
            <h1>Solicitud procesada</h1>
            <p>Mensaje: Solicitud procesada desde IP: \${HOST} y puerto: \${PORT}</p>
            <p>Data: \${Math.floor(Math.random() * 89999999 + 10000000)}</p>
            <p>PID: \${PID}</p>
         </body>
      </html>
   \`;
   res.send(htmlResponse);
});

app.listen(PORT, function () {
   console.log('Servicio iniciado en: ' + SCHEME + '://' + HOST + ':' + PORT + '!');
});

/* Registro del servicio en Consul */
var check = {
 id: SERVICE_ID,
 name: SERVICE_NAME,
 address: HOST,
 port: PORT,
 check: {
           http: SCHEME + '://' + HOST + ':' + PORT + '/health',
           ttl: '5s',
           interval: '5s',
           timeout: '5s',
           deregistercriticalserviceafter: '1m'
         }
};

consul.agent.service.register(check, function(err) {
   if (err) {
       console.error('Error registrando el servicio en Consul:', err);
       return;
   }
   console.log('Servicio registrado en Consul');
});
EOF

# Iniciar Consul en modo servidor   
sudo chown -R vagrant:vagrant /home/vagrant/consul_data    
consul agent -server -bootstrap-expect=1 -node=clienteUbuntu -bind=192.168.100.101 -client=0.0.0.0 -data-dir=. -ui &

chmod +x server.js 