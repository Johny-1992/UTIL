#!/bin/bash
pkg update -y
pkg install -y nodejs git clang cmake python openssl

npm install -g pnpm hardhat vercel

echo "ENV READY"
