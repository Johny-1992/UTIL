#!/bin/bash
cd backend
pnpm init -y
pnpm add express cors ethers

cat > api/index.ts <<'EOF'
import express from "express";
const app = express();
app.get("/health", (_, res) => res.json({ status: "ok" }));
app.listen(3000);
EOF

echo "BACKEND READY"
