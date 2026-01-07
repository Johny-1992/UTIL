import React, { useEffect, useState } from "react";
import { checkHealth } from "./services/health";

function App() {
  const [status, setStatus] = useState<"loading" | "ok" | "error">("loading");

  useEffect(() => {
    checkHealth().then((res) => {
      if (res?.status === "ok") {
        setStatus("ok");
      } else {
        setStatus("error");
      }
    });
  }, []);

  return (
    <div style={{ padding: "40px", fontFamily: "Arial" }}>
      <h1>🚀 OmniUtil</h1>

      {status === "loading" && <p>⏳ Vérification du backend...</p>}

      {status === "ok" && (
        <p style={{ color: "green", fontWeight: "bold" }}>
          ✅ Backend connecté et opérationnel
        </p>
      )}

      {status === "error" && (
        <p style={{ color: "red", fontWeight: "bold" }}>
          ❌ Backend inaccessible
        </p>
      )}
    </div>
  );
}

export default App;
