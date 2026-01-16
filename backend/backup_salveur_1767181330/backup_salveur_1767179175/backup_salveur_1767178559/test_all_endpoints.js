// test_all_endpoints.js
const axios = require('axios');

// Base URL de ton API
const baseURL = 'http://127.0.0.1:3000';

// Définir tous les endpoints GET à tester
const getEndpoints = [
    '/health',
    '/api/index',
    // ajoute ici d'autres endpoints GET si besoin
];

// Définir tous les endpoints POST à tester avec leurs données de test
const postEndpoints = [
    { path: '/api/partner/onboard', data: { user_id: '123' } },
    { path: '/api/ai/test', data: { input: 'test de fonctionnement' } },
    // ajoute ici d'autres endpoints POST
];

// Fonction pour tester un GET
async function testGET(path) {
    try {
        const res = await axios.get(baseURL + path);
        console.log(`GET ${path} ✅ Status: ${res.status}`);
        console.log('Response:', res.data);
    } catch (err) {
        if (err.response) {
            console.log(`GET ${path} ❌ Status: ${err.response.status}`);
            console.log('Response:', err.response.data);
        } else {
            console.log(`GET ${path} ❌ Error:`, err.message);
        }
    }
    console.log('------------------------');
}

// Fonction pour tester un POST
async function testPOST(path, data) {
    try {
        const res = await axios.post(baseURL + path, data, {
            headers: { 'Content-Type': 'application/json' }
        });
        console.log(`POST ${path} ✅ Status: ${res.status}`);
        console.log('Response:', res.data);
    } catch (err) {
        if (err.response) {
            console.log(`POST ${path} ❌ Status: ${err.response.status}`);
            console.log('Response:', err.response.data);
        } else {
            console.log(`POST ${path} ❌ Error:`, err.message);
        }
    }
    console.log('------------------------');
}

// Exécution de tous les tests
(async () => {
    console.log('=== TEST DES ENDPOINTS GET ===');
    for (const endpoint of getEndpoints) {
        await testGET(endpoint);
    }

    console.log('=== TEST DES ENDPOINTS POST ===');
    for (const endpoint of postEndpoints) {
        await testPOST(endpoint.path, endpoint.data);
    }
})();
