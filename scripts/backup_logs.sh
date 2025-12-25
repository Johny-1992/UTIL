#!/bin/bash

# Dossier des logs
LOG_DIR="~/omniutil/scripts"
BACKUP_DIR="~/omniutil/backups"

# Créer le dossier de sauvegarde s'il n'existe pas
mkdir -p $BACKUP_DIR

# Sauvegarder les logs
cp $LOG_DIR/keep_alive.log $BACKUP_DIR/keep_alive_$(date +%Y%m%d_%H%M%S).log
cp $LOG_DIR/test_all_endpoints.log $BACKUP_DIR/test_all_endpoints_$(date +%Y%m%d_%H%M%S).log

echo "Logs sauvegardés dans $BACKUP_DIR"
