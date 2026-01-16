import QRCode from 'qrcode';

interface OmniUtilQRData {
  type: string;
  id: string;
  timestamp: string;
  action: string;
  api_url: string;
}

// QR code unique pour OmniUtil
const OMNUTIL_UNIQUE_ID = "omniutil_global_id";
const OMNUTIL_API_URL = "https://api.omniutil.com/partner/request";

export async function generateOmniutilQR(): Promise<string | null> {
  const qrData: OmniUtilQRData = {
    type: "omniutil_unique_qr",
    id: OMNUTIL_UNIQUE_ID,
    timestamp: new Date().toISOString(),
    action: "request_partnership",
    api_url: OMNUTIL_API_URL
  };

  try {
    return await QRCode.toDataURL(JSON.stringify(qrData));
  } catch (err) {
    console.error('Erreur génération QR:', err);
    return null;
  }
}
