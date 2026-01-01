export function exchangeUTIL(user: string, service: string, amount: number) {
  return { user, service, amount, status: "exchanged" };
}
