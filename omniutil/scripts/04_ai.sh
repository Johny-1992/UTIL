#!/bin/bash
cd backend/ai

cat > scoring_engine.cpp <<'EOF'
#include <iostream>
extern "C" int score(int activity) {
    return activity * 2;
}
EOF

clang++ -shared -o libscore.so scoring_engine.cpp

echo "AI ENGINE READY"
