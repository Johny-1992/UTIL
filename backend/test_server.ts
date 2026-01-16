import express from "express";

const app = express();
const PORT = 8080;

app.get("/health", (_req, res) => {
    res.status(200).json({ status: "ok" });
});

app.listen(PORT, () => {
    console.log(`Test server running on port ${PORT}`);
});
