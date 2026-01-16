import { Router } from "express";
const router = Router();

router.get("/", (_, res) => {
    res.json({ status: "ok", module: "module3" });
});

export default router;
