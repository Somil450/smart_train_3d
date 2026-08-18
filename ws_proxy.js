const WebSocket = require('ws');

const ESP32_WS_URL = 'ws://10.143.186.193:81';
const LOCAL_WS_PORT = 8081;

// Start a local WS server for Flutter to connect to
const wss = new WebSocket.Server({ host: '0.0.0.0', port: LOCAL_WS_PORT }, () => {
    console.log(`[Proxy] Local WebSocket Server started on ws://localhost:${LOCAL_WS_PORT}`);
});

let esp32Ws = null;

function connectToESP32() {
    if (esp32Ws) {
        esp32Ws.terminate();
    }
    
    console.log(`[Proxy] Connecting to ESP32 at ${ESP32_WS_URL}...`);
    esp32Ws = new WebSocket(ESP32_WS_URL);

    esp32Ws.on('open', () => {
        console.log('[Proxy] Connected to ESP32!');
    });

    esp32Ws.on('message', (data) => {
        console.log(`[Proxy] Received ${data.length} bytes from ESP32`);
        // Broadcast the data from ESP32 to all connected Flutter clients
        wss.clients.forEach((client) => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(data.toString());
            }
        });
    });

    esp32Ws.on('close', () => {
        console.log('[Proxy] Connection to ESP32 closed. Reconnecting in 2s...');
        setTimeout(connectToESP32, 2000);
    });

    esp32Ws.on('error', (err) => {
        console.error('[Proxy] ESP32 connection error:', err.message);
        esp32Ws.close();
    });
}

// Initial connection
connectToESP32();
