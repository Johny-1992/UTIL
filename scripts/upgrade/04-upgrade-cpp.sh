#!/bin/bash
echo "🚀 Upgrade C++ Orchestrateur"
cd /root/omniutil/cpp || exit

# Compilation (adapté selon ton Makefile ou build)
if [ -f Makefile ]; then
    make
    echo "✅ C++ Orchestrateur compilé"
else
    echo "⚠️ Makefile non trouvé, vérifie le dossier cpp"
fi
