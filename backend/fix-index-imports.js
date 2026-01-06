// fix-index-imports.js
// But : convertir tous les imports de dossiers en imports explicites vers index.js pour ESM

import fs from 'fs';
import path from 'path';

const SRC_DIR = path.join(process.cwd(), 'src');

function fixImportsInFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf-8');
  const original = content;

  // Regex pour matcher : import X from './dossier';
  content = content.replace(
    /import\s+([\s\S]+?)\s+from\s+['"](\.\/[\w\/-]+)['"]/g,
    (match, imports, importPath) => {
      const absPath = path.resolve(path.dirname(filePath), importPath);
      const indexTs = absPath + '/index.ts';
      const indexJs = absPath + '/index.js';

      if (fs.existsSync(indexTs) || fs.existsSync(indexJs)) {
        return `import ${imports} from '${importPath}/index.js'`;
      }
      return match; // pas de changement
    }
  );

  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf-8');
    console.log(`✅ ${path.relative(process.cwd(), filePath)} corrigé`);
  }
}

function traverseDir(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) traverseDir(fullPath);
    else if (entry.isFile() && fullPath.endsWith('.ts')) fixImportsInFile(fullPath);
  }
}

traverseDir(SRC_DIR);
console.log('🎉 Tous les imports de dossiers ont été convertis en imports index.js');
