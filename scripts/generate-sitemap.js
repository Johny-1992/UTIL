import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 🌍 URL officielle du site (stable Vercel)
const BASE_URL = "https://omniutil.vercel.app";

// Routes EXISTANTES uniquement
const ROUTES = [
  "/",
  "/dashboard",
  "/rewards",
  "/airdrops",
  "/nft"
];

const sitemapPath = path.join(
  __dirname,
  "../frontend/public/sitemap.xml"
);

let xml = `<?xml version="1.0" encoding="UTF-8"?>\n`;
xml += `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n`;

for (const route of ROUTES) {
  xml += `  <url>\n`;
  xml += `    <loc>${BASE_URL}${route}</loc>\n`;
  xml += `    <changefreq>weekly</changefreq>\n`;
  xml += `    <priority>0.8</priority>\n`;
  xml += `  </url>\n`;
}

xml += `</urlset>\n`;

fs.writeFileSync(sitemapPath, xml, "utf-8");

console.log("✅ sitemap.xml généré avec succès :", sitemapPath);
