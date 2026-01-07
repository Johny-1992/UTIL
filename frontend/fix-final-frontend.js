// fix-final-frontend.js
import fs from 'fs';
import path from 'path';

// Dossier racine du frontend
const FRONTEND_DIR = path.resolve('.'); // <-- racine actuelle

// Fichier package.json
const PACKAGE_JSON = path.join(FRONTEND_DIR, 'package.json');

// Ajouter "type": "module" si manquant
if (fs.existsSync(PACKAGE_JSON)) {
  const pkg = JSON.parse(fs.readFileSync(PACKAGE_JSON, 'utf-8'));
  if (pkg.type !== 'module') {
    pkg.type = 'module';
    fs.writeFileSync(PACKAGE_JSON, JSON.stringify(pkg, null, 2));
    console.log('✅ package.json mis à jour avec "type": "module"');
  } else {
    console.log('✅ package.json déjà en "module"');
  }
}

// Fonction récursive pour parcourir tous les fichiers
function walkFiles(dir, callback) {
  const files = fs.readdirSync(dir, { withFileTypes: true });
  for (const file of files) {
    const fullPath = path.join(dir, file.name);
    if (file.isDirectory()) {
      walkFiles(fullPath, callback);
    } else if (file.name.endsWith('.js') || file.name.endsWith('.ts')) {
      callback(fullPath);
    }
  }
}

// Correction des imports pour ESM (ajouter .js si nécessaire)
walkFiles(FRONTEND_DIR, (filePath) => {
  let content = fs.readFileSync(filePath, 'utf-8');

  // Transformer require() en import si besoin
  content = content.replace(/require\(['"](.+?)['"]\)/g, (match, p1) => {
    if (p1.startsWith('.') && !p1.endsWith('.js')) {
      return `await import('${p1}.js')`;
    }
    return match;
  });

  // Transformer export const XX = en export const XX =
  content = content.replace(/exports\.(\w+)\s*=/g, 'export const $1 =');

  fs.writeFileSync(filePath, content);
  console.log(`✅ ${filePath.replace(FRONTEND_DIR + '/', '')} corrigé`);
});

console.log('🎉 Tous les fichiers frontend sont prêts pour ESM !');
