#!/bin/bash

# Nom du nouvel endpoint
ENDPOINT_NAME=$1

# Créer un fichier pour le nouvel endpoint
nano ~/omniutil/backend/src/api/$ENDPOINT_NAME.ts
