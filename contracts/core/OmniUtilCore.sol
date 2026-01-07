// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OmniUtilCore is ERC20, Ownable {

    address public CREATOR;
    address public TREASURY;
    address public AI_COORDINATOR;

    enum PartnerLevel { NONE, BASIC, VERIFIED, CERTIFIED, ELITE }

    mapping(address => bool) public isPartner;
    mapping(address => PartnerLevel) public partnerLevel;
    mapping(address => uint256) public partnerRewardRates;
    mapping(address => uint256) public loyaltyFactor;
    mapping(address => address) public userEcosystem;

    uint256 public maxAnnualMint;
    uint256 public mintedThisYear;
    uint256 public lastReset;

    struct ServiceExchange {
        address user;
        string serviceDescription;
        uint256 amount;
        uint256 timestamp;
    }

    ServiceExchange[] public serviceExchanges;
    uint256 public usdtExchangeRate = 1;

    event PartnerAdded(address indexed partner, uint256 rewardRate);
    event PartnerCertified(address indexed partner, PartnerLevel level, uint256 timestamp);
    event RewardClaimed(address indexed user, uint256 reward, uint256 usdValue);
    event FeeDistributed(address indexed to, uint256 amount, string feeType);
    event ServiceExchangedEvent(address indexed user, string serviceDescription, uint256 amount);
    event USDTExchanged(address indexed user, uint256 amount);
    event TransferInEcosystem(address indexed from, address indexed to, uint256 amount);
    event FraudDetected(address indexed user, string reason);
    event MiettesDistributed(address indexed influencer, uint256 amount);

    modifier onlyAICoordinator() {
        require(msg.sender == AI_COORDINATOR, "Not AI coordinator");
        _;
    }

    modifier inflationGuard(uint256 amount) {
        if(block.timestamp > lastReset + 365 days){
            mintedThisYear = 0;
            lastReset = block.timestamp;
        }
        require(mintedThisYear + amount <= maxAnnualMint, "Mint cap exceeded");
        _;
        mintedThisYear += amount;
    }

    constructor(address _creator, address _treasury, address _ai) ERC20("OmniUtil", "UTIL") Ownable(msg.sender) {
        CREATOR = _creator;
        TREASURY = _treasury;
        AI_COORDINATOR = _ai;

        _mint(msg.sender, 1_000_000 * 10 ** decimals());
        maxAnnualMint = 10_000_000 * 10 ** decimals();
        lastReset = block.timestamp;
    }

    function addPartner(address partner, uint256 rewardRate, address ecosystem, uint256 _loyalty) external onlyOwner {
        require(!isPartner[partner], "Already partner");
        isPartner[partner] = true;
        partnerRewardRates[partner] = rewardRate;
        userEcosystem[partner] = ecosystem;
        loyaltyFactor[partner] = _loyalty;
        partnerLevel[partner] = PartnerLevel.BASIC;
        emit PartnerAdded(partner, rewardRate);
    }

    function updatePartnerParams(address partner, uint256 newRate, PartnerLevel level, uint256 newLoyalty) external onlyAICoordinator {
        require(isPartner[partner], "Not partner");
        partnerRewardRates[partner] = newRate;
        partnerLevel[partner] = level;
        loyaltyFactor[partner] = newLoyalty;
        emit PartnerCertified(partner, level, block.timestamp);
    }

    function claimReward(address partner, uint256 amountSpentUSD) external inflationGuard(amountSpentUSD * partnerRewardRates[partner] / 100) {
        require(isPartner[partner], "Invalid partner");
        require(amountSpentUSD > 0, "Invalid amount");

        uint256 baseReward = (amountSpentUSD * partnerRewardRates[partner]) / 100;
        uint256 loyaltyBonus = (baseReward * loyaltyFactor[msg.sender]) / 100;
        uint256 reward = baseReward + loyaltyBonus;

        uint256 copyrightFee = reward / 100;
        uint256 networkFee = reward / 100;
        uint256 finalReward = reward - copyrightFee - networkFee;

        _mint(msg.sender, finalReward);
        _mint(CREATOR, copyrightFee);
        _mint(TREASURY, networkFee);

        emit RewardClaimed(msg.sender, finalReward, amountSpentUSD);
        emit FeeDistributed(CREATOR, copyrightFee, "Copyright");
        emit FeeDistributed(TREASURY, networkFee, "Network");
    }

    function exchangeForService(uint256 amount, string calldata description) external {
        require(isPartner[msg.sender], "Only partner");
        _burn(msg.sender, amount);
        serviceExchanges.push(ServiceExchange(msg.sender, description, amount, block.timestamp));
        emit ServiceExchangedEvent(msg.sender, description, amount);
    }

    function exchangeForUSDT(uint256 amount) external {
        _burn(msg.sender, amount);
        emit USDTExchanged(msg.sender, amount);
    }

    function transferInEcosystem(address to, uint256 amount) external {
        require(userEcosystem[msg.sender] == userEcosystem[to], "Different ecosystem");
        _transfer(msg.sender, to, amount);
        emit TransferInEcosystem(msg.sender, to, amount);
    }

    function distributeMiettes(address[] calldata influencers, uint256 totalNetworkFee) external onlyOwner {
        require(influencers.length > 0, "No influencers");
        uint256 miettesPer = (totalNetworkFee * 10) / (100 * influencers.length);
        for(uint256 i=0;i<influencers.length;i++){
            _mint(influencers[i], miettesPer);
            emit MiettesDistributed(influencers[i], miettesPer);
        }
    }

    function flagFraud(address user, string calldata reason) external onlyOwner {
        emit FraudDetected(user, reason);
    }

    function setUsdtExchangeRate(uint256 rate) external onlyOwner {
        usdtExchangeRate = rate;
    }

    function mintForStability(uint256 amount) external onlyOwner inflationGuard(amount){
        _mint(TREASURY, amount);
    }

    function burnForStability(uint256 amount) external onlyOwner{
        _burn(TREASURY, amount);
    }
}
