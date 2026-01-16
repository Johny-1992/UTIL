import express from 'express';
import fs from 'fs';
import path from 'path';
const app = express();
const PORT = process.env.PORT || 8082;
const PUBLIC_DIR = path.join(__dirname, '../../public');
app.use(express.static(PUBLIC_DIR));
app.get('/metadata.json', (req, res) => {
    const meta = fs.readFileSync(path.join(PUBLIC_DIR, 'metadata.json'), 'utf8');
    res.type('application/json').send(meta);
});
app.get('/health', (req, res) => {
    res.send({status:'Omniutil daemon actif', timestamp: Date.now()});
});
app.listen(PORT, () => console.log(`🌐 Omniutil Web Server running on port ${PORT}`));
