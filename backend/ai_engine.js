function evaluatePartner(data) {
  let score = 0;

  if (data.subscribers > 1000000) score += 40;
  if (data.country) score += 20;
  if (data.apiAvailable) score += 20;
  if (data.legalEntity) score += 20;

  return {
    score,
    approved: score >= 60
  };
}

module.exports = { evaluatePartner };
