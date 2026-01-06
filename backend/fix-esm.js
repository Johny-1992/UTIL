import fs from 'fs';
import path from 'path';

const SRC_DIR = './src';

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf-8');

  // 1️⃣ Ajouter .js aux imports relatifs
  content = content.replace(
    /(import\s+.*?\s+from\s+['"])(\.\/.*?)(['"])/g,
    (match, p1, p2, p3) => {
      if (p2.endsWith('.js') || p2.endsWith('.ts') || p2.endsWith('.json')) return match;
      return `${p1}${p2}.js${p3}`;
    }
  );

  // 2️⃣ Convertir module.exports = ... en export default ...
  content = content.replace(
    /module\.exports\s*=\s*(\{[\s\S]*?\}|[^\n;]+);?/g,
    (match, p1) => `export default ${p1};`
  );

  // 3️⃣ Convertir exports.foo = ... en export const foo = ...
  content = content.replace(
    /exports\.(\w+)\s*=\s*(.+);?/g,
    (match, p1, p2) => `export const ${p1} = ${p2};`
  );

  fs.writeFileSync(filePath, content, 'utf-8');
  console.log(`✅ ${filePath} corrigé`);
}

function walkDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) walkDir(fullPath);
    else if (file.endsWith('.ts')) processFile(fullPath);
  }
}

walkDir(SRC_DIR);
console.log('🎉 Tous les fichiers TS ont été convertis pour ESM !');
