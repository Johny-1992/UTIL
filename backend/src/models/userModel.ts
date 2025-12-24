export async function updateUserBalance(userId: string, amount: number) {
  const users = { u1: 100, u2: 200 };
  users[userId] += amount;
  return users[userId];
}
