#!/bin/bash
cd frontend/landing

cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<body>
<h1>OMNIUTIL</h1>
<p>Universal Utility Protocol</p>
</body>
</html>
EOF

echo "FRONTEND READY"
