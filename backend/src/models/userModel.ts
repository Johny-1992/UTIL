export interface User {
  balance: number;
}

export const users: Record<string, User> = {
  u1: { balance: 1000 },
  u2: { balance: 500 }
};

export const updateUserBalance = (userId: string, delta: number) => {
  users[userId] = users[userId] || { balance: 0 };
  users[userId].balance += delta;
};
