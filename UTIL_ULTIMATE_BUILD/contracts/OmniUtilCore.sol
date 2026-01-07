// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OmniUtil is ERC20, Ownable {

    address public CREATOR = 0xYourCreatorAddressHere;
    address public TREASURY = 0xYourTreasuryAddressHere;
    address public AI_COORDINATOR = 0xYourAICoordinatorHere;

    uint256 public usdtExchangeRate = 1;

    struct Partner {
        bool exists;
        uint256 rewardRate;
        address ecosystem;
        uint256 loyaltyFactor;
    }

    struct ServiceExchange {
        address user;
        string serviceDescription;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Partner) public partners;
    mapping(address => uint256) public mintedThisYear;
    mapping(address => uint256) public lastReset;
    ServiceExchange[] public serviceExchanges;

    event PartnerAdded(address indexed partner, uint256 rewardRate);
    event RewardClaimed(address indexed user, uint256 amount, uint256 usdValue);
    event ServiceExchanged(address indexed user, string serviceDescription, uint256 amount);
    event USDTExchanged(address indexed user, uint256 amount);
    event TransferInEcosystem(address indexed from, address indexed to, uint256 amount);
    event FeeDistributed(address indexed to, uint256 amount, string feeType);
    event MiettesDistributed(address indexed influencer, uint256 amount);
    event FraudDetected(address indexed user, string reason);

    modifier onlyAICoordinator() {
        require(msg.sender == AI_COORDINATOR, "Not AI Coordinator");
        _;
    }

    constructor() ERC20("OmniUtil", "UTIL") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    // --- PARTNER MANAGEMENT ---
    function addPartner(address _partner, uint256 _rewardRate, address _ecosystem, uint256 _loyalty) external onlyOwner {
        require(!partners[_partner].exists, "Partner exists");
        partners[_partner] = Partner(true, _rewardRate, _ecosystem, _loyalty);
        emit PartnerAdded(_partner, _rewardRate);
    }

    // --- REWARDS ---
    function claimReward(address _partner, uint256 amountUSD) external {
        require(partners[_partner].exists, "Invalid partner");
        uint256 baseReward = (amountUSD * partners[_partner].rewardRate) / 100;
        uint256 loyaltyBonus = (baseReward * partners[_partner].loyaltyFactor) / 100;
        uint256 reward = baseReward + loyaltyBonus;

        uint256 copyrightFee = reward / 100;
        uint256 networkFee = reward / 100;
        uint256 finalReward = reward - copyrightFee - networkFee;

        _mint(msg.sender, finalReward);
        _mint(CREATOR, copyrightFee);
        _mint(TREASURY, networkFee);

        emit RewardClaimed(msg.sender, finalReward, amountUSD);
        emit FeeDistributed(CREATOR, copyrightFee, "Copyright Fee");
        emit FeeDistributed(TREASURY, networkFee, "Network Fee");
    }

    // --- SERVICE & USDT EXCHANGE ---
    function exchangeForService(uint256 amount, string memory description) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(partners[msg.sender].exists, "Only partner");
        _burn(msg.sender, amount);
        serviceExchanges.push(ServiceExchange(msg.sender, description, amount, block.timestamp));
        emit ServiceExchanged(msg.sender, description, amount);
    }

    function exchangeForUSDT(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        emit USDTExchanged(msg.sender, amount);
    }

    // --- ECOSYSTEM TRANSFER ---
    function transferInEcosystem(address to, uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(partners[msg.sender].ecosystem == partners[to].ecosystem, "Different ecosystem");
        _transfer(msg.sender, to, amount);
        emit TransferInEcosystem(msg.sender, to, amount);
    }

    // --- STABILITY ---
    function mintForStability(uint256 amount) external onlyOwner {
        _mint(TREASURY, amount);
    }

    function burnForStability(uint256 amount) external onlyOwner {
        _burn(TREASURY, amount);
    }

    // --- AI Coordinator functions ---
    function setAICoordinator(address ai) external onlyOwner {
        AI_COORDINATOR = ai;
    }

    function updatePartnerParams(address partner, uint256 newRate, uint256 newLoyalty) external onlyAICoordinator {
        require(partners[partner].exists, "Not a partner");
        partners[partner].rewardRate = newRate;
        partners[partner].loyaltyFactor = newLoyalty;
    }

    // --- FRAUD DETECTION ---
    function flagFraud(address user, string memory reason) external onlyOwner {
        emit FraudDetected(user, reason);
    }

    function setUsdtExchangeRate(uint256 rate) external onlyOwner {
        usdtExchangeRate = rate;
    }
}
