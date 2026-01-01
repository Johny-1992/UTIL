#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
GITHUB_USERNAME="Johny-1992"
REPO_NAME="UTIL"
BRANCH_NAME="main"
LOCAL_DIR="$(pwd)"   # Assure-toi d'être dans /root/omniutil ou /root/omniutil/backend
COMMIT_MSG="OmniUtil -> UTIL - Projet complet, scripts salvateurs, backend & contracts"

# --- Vérifications ---
echo "📁 Répertoire local : $LOCAL_DIR"
command -v git >/dev/null 2>&1 || { echo "❌ git n'est pas installé"; exit 1; }

# --- Supprimer ancien remote pour éviter conflit ---
git remote remove origin 2>/dev/null || true

# --- Créer le repo sur GitHub via API ---
echo "🌐 Création du dépôt GitHub $REPO_NAME..."
curl -s -u "$GITHUB_USERNAME" https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\", \"private\": false}" >/dev/null || true

# --- Initialiser git si ce n'est pas déjà fait ---
if [ ! -d ".git" ]; then
    echo "🔧 Initialisation git locale..."
    git init
fi

# --- Ajouter tous les fichiers essentiels ---
echo "📦 Ajout des fichiers au commit..."
git add .

# --- Commit propre ---
git commit -m "$COMMIT_MSG" || echo "⚠️ Rien à commit, déjà à jour"

# --- Config postBuffer pour gros fichiers ---
git config http.postBuffer 524288000  # 500MB

# --- Ajouter remote et pousser ---
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M $BRANCH_NAME
echo "⬆️ Poussée vers GitHub..."
git push -u origin $BRANCH_NAME --force

echo "✅ Projet poussé avec succès sur https://github.com/$GITHUB_USERNAME/$REPO_NAME"
