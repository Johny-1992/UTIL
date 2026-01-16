// list_routes.js
const app = require('./dist/index'); // index.js compilé

if (!app._router) {
  console.log("Aucune route détectée. Vérifie que dist/index.js exporte l'app Express.");
  process.exit(1);
}

const routes = app._router.stack
  .filter(r => r.route)
  .map(r => ({
    path: r.route.path,
    methods: Object.keys(r.route.methods).join(', ')
  }));

console.log("Routes disponibles et méthodes :");
console.table(routes);
