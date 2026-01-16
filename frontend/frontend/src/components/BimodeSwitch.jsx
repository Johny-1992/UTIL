import React, { useState, useEffect } from "react";

const BimodeSwitch = () => {
  const [mode, setMode] = useState("demo");

  useEffect(() => {
    const storedMode = localStorage.getItem("OMNI_MODE");
    if (storedMode) setMode(storedMode);
  }, []);

  const toggleMode = () => {
    const newMode = mode === "demo" ? "real" : "demo";
    setMode(newMode);
    localStorage.setItem("OMNI_MODE", newMode);
    alert(`Mode changé vers : ${newMode.toUpperCase()}`);
  };

  return (
    <div style={{ position: "fixed", top: 10, right: 10, zIndex: 999 }}>
      <button
        onClick={toggleMode}
        style={{
          padding: "10px 20px",
          backgroundColor: mode === "demo" ? "#f39c12" : "#27ae60",
          color: "#fff",
          border: "none",
          borderRadius: "5px",
          cursor: "pointer",
        }}
      >
        {mode === "demo" ? "Mode Démo" : "Mode Réel"}
      </button>
    </div>
  );
};

export default BimodeSwitch;
