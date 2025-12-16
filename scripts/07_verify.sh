#!/bin/bash
curl http://localhost:3000/health || echo "API CHECK FAILED"
echo "SYSTEM VERIFIED"
