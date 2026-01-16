extern "C" double score(double usage, double trust) {
  return (usage * 0.7) + (trust * 0.3);
}
