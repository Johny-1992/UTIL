import { Router } from "express";
const router = Router();

router.get("/", (_, res) => {
  res.json({ status: "ok", module: "module2", timestamp: Date.now() });
});

export default router;
