import express from "express";
import dotenv from "dotenv";
dotenv.config();

const app = express();
app.use(express.json());

app.get("/health", (_, res) => {
  res.json({ status: "OmniUtil backend OK" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("🚀 OmniUtil backend running on port", PORT);
});
