export function onQRScan(entity: any) {
  return {
    type: "PARTNER_REQUEST",
    payload: entity,
    timestamp: Date.now()
  };
}
