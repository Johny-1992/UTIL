// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Copyright {
    address public owner = 0x40BB46B9D10Dd121e7D2150EC3784782ae648090;
    string public rights = "OMNIUTIL intellectual property locked on-chain";

    function verify() public view returns (string memory) {
        return rights;
    }
}
