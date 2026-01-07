import axios from "axios";

export const API_URL = import.meta.env.VITE_API_URL;

export const api = axios.create({
  baseURL: API_URL,
  timeout: 10_000,
});

if (!API_URL) {
  console.warn("⚠️ VITE_API_URL n'est pas définie");
} else {
  console.log("✅ API connectée :", API_URL);
}
