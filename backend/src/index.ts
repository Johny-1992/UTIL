import app from "./api";

const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log("🚀 OMNIUTIL API running on port " + port);
});
