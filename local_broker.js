const { Aedes } = require('aedes');
const aedes = new Aedes();
const server = require('net').createServer(aedes.handle);
const httpServer = require('http').createServer();
const ws = require('websocket-stream');

const MQTT_PORT = 1883;
const WS_PORT = 9001;

// Start traditional MQTT server (for ESP32)
server.listen(MQTT_PORT, function () {
  console.log('Aedes MQTT server started and listening on port', MQTT_PORT);
});

// Start WebSocket MQTT server (for Flutter Web app)
ws.createServer({ server: httpServer }, aedes.handle);

httpServer.listen(WS_PORT, function () {
  console.log('Aedes MQTT WebSocket server started and listening on port', WS_PORT);
});

aedes.on('client', function (client) {
  console.log('Client Connected: \x1b[33m' + (client ? client.id : client) + '\x1b[0m', 'to broker', aedes.id);
});

aedes.on('clientDisconnect', function (client) {
  console.log('Client Disconnected: \x1b[31m' + (client ? client.id : client) + '\x1b[0m', 'to broker', aedes.id);
});

aedes.on('publish', function (packet, client) {
  if (client) {
    console.log('Client \x1b[32m' + client.id + '\x1b[0m has published', packet.payload.toString(), 'on', packet.topic);
  }
});
