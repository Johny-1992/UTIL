import { Router } from "express";
import partner from "./partner_validation.js";
import ai from "./ai.js";
import fraudDetection from "./fraud_detection.js";

const router = Router();

router.get("/index", (_, res) => {
  res.json({ message: "API fonctionnelle !" });
});

router.use("/partner", partner);
router.use("/ai", ai);
router.use("/fraud", fraudDetection);

export default router;
