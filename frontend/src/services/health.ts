import { api } from "../config/api";

export async function checkHealth() {
  try {
    const res = await api.get("/health");
    return res.data;
  } catch (err) {
    console.error("❌ Backend inaccessible", err);
    return null;
  }
}
