import {
  calculateRewards,
  transferUtil,
  convertToUSDT
} from "../../services/rewardsService";

export const rewardController = async (req: any) =>
  calculateRewards(req.partnerId, req.userId, req.amountSpent);

export const transferController = async (req: any) =>
  transferUtil(req.fromUserId, req.toUserId, req.amount);

export const convertController = async (req: any) =>
  convertToUSDT(req.userId, req.amount);
