import { Router } from "express";
const router = Router();

router.get("/", (_, res) => {
  res.json({ status: "ok", module: "module1", timestamp: Date.now() });
});

export default router;
