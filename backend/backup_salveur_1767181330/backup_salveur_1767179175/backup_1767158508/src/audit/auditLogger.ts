import fs from "fs";
import crypto from "crypto";

export const audit = (action: string, payload: any) => {
  const timestamp = new Date().toISOString();
  const data = JSON.stringify({ action, payload, timestamp });
  const hash = crypto.createHash("sha256").update(data).digest("hex");

  const record = {
    action,
    timestamp,
    hash,
    payload
  };

  fs.appendFileSync(
    "audit.log",
    JSON.stringify(record) + "\n"
  );
};
