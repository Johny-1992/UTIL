import { Router } from "express";
const router = Router();

router.get("/", (_, res) => {
    res.json({ status: "ok", module: "module4" });
});

export default router;
