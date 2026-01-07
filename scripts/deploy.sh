#!/bin/bash
npx hardhat compile
npx hardhat run scripts/deploy.ts --network sepolia
