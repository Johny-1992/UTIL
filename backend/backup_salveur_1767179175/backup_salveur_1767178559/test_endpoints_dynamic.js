const axios = require('axios');
const fs = require('fs');
const path = require('path');

const baseURL = 'http://127.0.0.1:3000';
const apiDir = path.join(__dirname, 'dist/api');

// Fonction pour récupérer les routes d'un module Express
function extractRoutes(module) {
    if (!module || !module.stack) return [];
    return module.stack
        .filter(r => r.route)
        .map(r => ({
            path: r.route.path,
            methods: Object.keys(r.route.methods),
        }));
}

// Charger tous les fichiers .js dans dist/api
async function getAllRoutes() {
    const routes = [];
    const files = fs.readdirSync(apiDir).filter(f => f.endsWith('.js'));
    for (const file of files) {
        const modPath = path.join(apiDir, file);
        try {
            const router = require(modPath);
            const moduleRoutes = extractRoutes(router);
            moduleRoutes.forEach(r => routes.push(r));
        } catch (err) {
            console.log(`⚠️  Impossible de charger ${file}: ${err.message}`);
        }
    }
    return routes;
}

// Tester chaque route
async function testRoute(route) {
    for (const method of route.methods) {
        let data = null;
        if (method === 'post') data = { test: 'ok' }; // données de test POST
        try {
            const response = await axios({
                method,
                url: baseURL + route.path,
                data,
                headers: { 'Content-Type': 'application/json' },
                validateStatus: () => true
            });
            console.log(`${method.toUpperCase()} ${route.path} ✅ Status: ${response.status}`);
            console.log('Response:', response.data);
        } catch (err) {
            console.log(`${method.toUpperCase()} ${route.path} ❌ Erreur`);
            console.log(err.message);
        }
        console.log('------------------------');
    }
}

(async () => {
    console.log('=== TEST AUTOMATIQUE DYNAMIQUE DES ENDPOINTS ===\n');
    const routes = await getAllRoutes();
    if (routes.length === 0) return console.log('Aucune route détectée.');
    for (const route of routes) {
        await testRoute(route);
    }
    console.log('=== FIN DU TEST ===');
})();
