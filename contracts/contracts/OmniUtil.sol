// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OmniUtil is ERC20, Ownable {
    address public CREATOR;
    address public TREASURY;

    mapping(address => uint256) public partnerRewardRates;
    mapping(address => address) public userEcosystem;
    mapping(address => bool) public isPartner;
    mapping(address => uint256) public loyaltyFactor;

    struct ServiceExchange {
        address user;
        string serviceDescription;
        uint256 amount;
        uint256 timestamp;
    }

    ServiceExchange[] public serviceExchanges;
    uint256 public usdtExchangeRate = 1;

    event RewardClaimed(address indexed user, uint256 amount, uint256 usdValue);
    event ServiceExchanged(address indexed user, string serviceDescription, uint256 amount);
    event USDTExchanged(address indexed user, uint256 amount);
    event TransferInEcosystem(address indexed from, address indexed to, uint256 amount);
    event FeeDistributed(address indexed to, uint256 amount, string feeType);
    event PartnerAdded(address indexed partner, uint256 rewardRate);
    event MiettesDistributed(address indexed influencer, uint256 amount);
    event FraudDetected(address indexed user, string reason);

    constructor(address _creator, address _treasury)
        ERC20("OmniUtil", "UTIL")
        Ownable(msg.sender)
    {
        CREATOR = _creator;
        TREASURY = _treasury;
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function addPartner(
        address partner,
        uint256 _rewardRate,
        address ecosystem,
        uint256 _loyaltyFactor
    ) external onlyOwner {
        require(!isPartner[partner], "Partenaire deja existant");
        isPartner[partner] = true;
        partnerRewardRates[partner] = _rewardRate;
        userEcosystem[partner] = ecosystem;
        loyaltyFactor[partner] = _loyaltyFactor;
        emit PartnerAdded(partner, _rewardRate);
    }

    function claimReward(address partner, uint256 amountSpentUSD) external {
        require(isPartner[partner], "Partenaire non valide");
        require(amountSpentUSD > 0, "Montant doit etre > 0");

        uint256 rewardRate = partnerRewardRates[partner];
        uint256 reward = (amountSpentUSD * rewardRate) / 100;

        uint256 copyrightFee = (reward * 1) / 100;
        uint256 networkFee = (reward * 1) / 100;
        uint256 finalReward = reward - copyrightFee - networkFee;

        _mint(msg.sender, finalReward);
        _mint(CREATOR, copyrightFee);
        _mint(TREASURY, networkFee);

        emit RewardClaimed(msg.sender, finalReward, amountSpentUSD);
        emit FeeDistributed(CREATOR, copyrightFee, "Copyright Fee");
        emit FeeDistributed(TREASURY, networkFee, "Network Support Fee");
    }

    function exchangeForService(uint256 amount, string memory serviceDescription) external {
        require(balanceOf(msg.sender) >= amount, "Solde insuffisant");
        require(isPartner[msg.sender], "Seul un partenaire peut echanger des services");

        _burn(msg.sender, amount);

        serviceExchanges.push(ServiceExchange({
            user: msg.sender,
            serviceDescription: serviceDescription,
            amount: amount,
            timestamp: block.timestamp
        }));

        emit ServiceExchanged(msg.sender, serviceDescription, amount);
    }

    function exchangeForUSDT(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Solde insuffisant");
        _burn(msg.sender, amount);
        emit USDTExchanged(msg.sender, amount);
    }

    function transferInEcosystem(address to, uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Solde insuffisant");
        require(
            userEcosystem[msg.sender] == userEcosystem[to],
            "Transfert uniquement dans le meme ecosysteme"
        );
        _transfer(msg.sender, to, amount);
        emit TransferInEcosystem(msg.sender, to, amount);
    }

    function distributeMiettes(address[] memory influencers, uint256 totalNetworkFee)
        external
        onlyOwner
    {
        require(influencers.length > 0, "Aucun influenceur");
        uint256 miettesPerInfluencer =
            (totalNetworkFee * 10) / (100 * influencers.length);

        for (uint256 i = 0; i < influencers.length; i++) {
            _mint(influencers[i], miettesPerInfluencer);
            emit MiettesDistributed(influencers[i], miettesPerInfluencer);
        }
    }

    function flagFraud(address user, string memory reason) external onlyOwner {
        emit FraudDetected(user, reason);
    }

    function setUsdtExchangeRate(uint256 newRate) external onlyOwner {
        usdtExchangeRate = newRate;
    }

    function mintForStability(uint256 amount) external onlyOwner {
        _mint(TREASURY, amount);
    }

    function burnForStability(uint256 amount) external onlyOwner {
        _burn(TREASURY, amount);
    }
}
