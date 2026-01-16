export function onQRScan(ecosystemName: string, activeUsers: number) {
  return {
    ecosystemName,
    activeUsers,
    timestamp: Date.now()
  };
}
