import express from "express";
const app = express();
app.use(express.json());

app.get("/health", (_, res) => {
  res.json({ status: "OMNIUTIL API OK" });
});

app.listen(3000, () => console.log("API running on :3000"));
