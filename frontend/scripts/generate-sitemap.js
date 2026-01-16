import fs from 'fs';
const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://omniutil.vercel.app/</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>
  <url><loc>https://omniutil.vercel.app/dashboard</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>
  <url><loc>https://omniutil.vercel.app/rewards</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>
  <url><loc>https://omniutil.vercel.app/airdrops</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>
  <url><loc>https://omniutil.vercel.app/nft</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>
</urlset>`;
fs.writeFileSync('public/sitemap.xml', sitemap);
console.log("✅ sitemap.xml généré")
