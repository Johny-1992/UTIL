// fix-final-backend.js
import fs from 'fs';
import path from 'path';

const ROOT = './src';

function fixImports(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      fixImports(fullPath);
    } else if (file.endsWith('.ts')) {
      let content = fs.readFileSync(fullPath, 'utf8');

      // Ajouter .js aux imports relatifs
      content = content.replace(
        /from\s+['"](\..*?)['"]/g,
        (match, p1) => {
          if (p1.endsWith('.js') || p1.endsWith('.json')) return match;
          // Vérifie si c'est un dossier
          const importPath = path.join(path.dirname(fullPath), p1);
          if (fs.existsSync(importPath) && fs.statSync(importPath).isDirectory()) {
            return `from '${p1}/index.js'`;
          }
          return `from '${p1}.js'`;
        }
      );

      fs.writeFileSync(fullPath, content);
      console.log(`✅ ${fullPath} corrigé`);
    }
  }
}

// Fix package.json
const pkg = JSON.parse(fs.readFileSync('./package.json', 'utf8'));
pkg.type = 'module';
fs.writeFileSync('./package.json', JSON.stringify(pkg, null, 2));
console.log('✅ package.json mis à jour avec "type": "module"');

// Fix tsconfig.json
const tsconfig = {
  compilerOptions: {
    target: "ES2022",
    module: "NodeNext",
    moduleResolution: "NodeNext",
    outDir: "dist",
    rootDir: "src",
    esModuleInterop: true,
    forceConsistentCasingInFileNames: true,
    strict: true,
    skipLibCheck: true
  }
};
fs.writeFileSync('./tsconfig.json', JSON.stringify(tsconfig, null, 2));
console.log('✅ tsconfig.json mis à jour');

// Applique les fixes
fixImports(ROOT);
console.log('🎉 Tous les fichiers TS sont prêts pour ESM !');
