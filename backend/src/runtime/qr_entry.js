module.exports.onQRScan = function(entity) {
  return {
    type: "PARTNER_REQUEST",
    payload: entity,
    timestamp: Date.now()
  };
};
