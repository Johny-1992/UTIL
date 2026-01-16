// test_endpoints.js
const axios = require('axios');

// Liste des endpoints à tester
const endpoints = [
    '/api/index',
    // Ajoute ici tous tes endpoints existants, ex:
    // '/api/partner/onboard',
    // '/api/ai/test',
];

const baseURL = 'http://127.0.0.1:3000';

(async () => {
    for (const endpoint of endpoints) {
        try {
            const res = await axios.get(baseURL + endpoint);
            console.log(`${endpoint} ✅ Status: ${res.status}`);
            console.log('Response:', res.data);
        } catch (err) {
            if (err.response) {
                console.log(`${endpoint} ❌ Status: ${err.response.status}`);
                console.log('Response:', err.response.data);
            } else {
                console.log(`${endpoint} ❌ Error:`, err.message);
            }
        }
        console.log('------------------------');
    }
})();
