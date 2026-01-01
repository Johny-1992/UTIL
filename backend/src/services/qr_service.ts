import { Buffer } from 'buffer';

export interface QrContext {
  partnerId: string;
  userId?: string;
  campaignId?: string;
  [key: string]: any;
}

export function encodeQrContext(ctx: QrContext): string {
  const json = JSON.stringify(ctx);
  return Buffer.from(json, 'utf-8').toString('base64url');
}

export function decodeQrContext(payload: string): QrContext {
  const json = Buffer.from(payload, 'base64url').toString('utf-8');
  return JSON.parse(json) as QrContext;
}

// Alias pour compatibilité avec ai.ts
export const encodeContext = encodeQrContext;
export const decodeContext = decodeQrContext;
