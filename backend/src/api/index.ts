import { Router } from "express";
import partner from "./partner_validation";
import ai from "./ai";
import fraudDetection from "./fraud_detection";

const router = Router();

router.get("/index", (_, res) => {
  res.json({ message: "API fonctionnelle !" });
});

router.use("/partner", partner);
router.use("/ai", ai);
router.use("/fraud", fraudDetection);

export default router;
