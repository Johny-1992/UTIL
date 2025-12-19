pragma solidity ^0.8.20;

contract MeritEngine {
    function score(address user) external pure returns(uint256) {
        return uint256(uint160(user)) % 100;
    }
}
