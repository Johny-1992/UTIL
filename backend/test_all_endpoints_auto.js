const axios = require('axios');

const baseURL = 'http://127.0.0.1:3000'; // Base de l'API

// Liste de tous les endpoints à tester
const endpoints = [
    { method: 'get', path: '/health', data: null },
    { method: 'get', path: '/api/index', data: null },
    { method: 'post', path: '/api/partner/onboard', data: { user_id: '123' } },
    { method: 'post', path: '/api/ai/test', data: { input: 'test de fonctionnement' } },
];

async function testEndpoint(endpoint) {
    try {
        const response = await axios({
            method: endpoint.method,
            url: baseURL + endpoint.path,
            data: endpoint.data,
            headers: { 'Content-Type': 'application/json' },
            validateStatus: () => true // pour capturer tous les codes HTTP
        });
        console.log(`${endpoint.method.toUpperCase()} ${endpoint.path} ✅ Status: ${response.status}`);
        console.log('Response:', response.data);
    } catch (err) {
        console.log(`${endpoint.method.toUpperCase()} ${endpoint.path} ❌ Erreur`);
        console.log(err.message);
    }
    console.log('------------------------');
}

(async () => {
    console.log('=== TEST AUTOMATIQUE DES ENDPOINTS ===\n');
    for (const ep of endpoints) {
        await testEndpoint(ep);
    }
    console.log('=== FIN DU TEST ===');
})();
