import React from "react";

export default function Home() {
  return (
    <div style={{ padding: "40px", maxWidth: "900px", margin: "auto" }}>
      <h1>🚀 OmniUtil</h1>

      <p>
        OmniUtil est une plateforme utilitaire combinant Web, Backend, Blockchain
        et orchestration intelligente.
      </p>

      <h2>✨ Fonctionnalités</h2>
      <ul>
        <li>✔️ Frontend React déployé</li>
        <li>✔️ Backend API opérationnel</li>
        <li>✔️ Smart contracts prêts</li>
        <li>✔️ Architecture évolutive</li>
      </ul>

      <h2>🔗 État du système</h2>
      <ul>
        <li>🌐 Frontend : OK</li>
        <li>🧠 Backend : OK</li>
        <li>⛓️ Blockchain : prêt</li>
      </ul>

      <button
        style={{
          padding: "12px 20px",
          fontSize: "16px",
          cursor: "pointer",
          marginTop: "20px"
        }}
      >
        Connecter un wallet (bientôt)
      </button>
    </div>
  );
}
