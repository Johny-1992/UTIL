// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

contract UTIL {
    mapping(address => uint256) public balance;
    function mint(address to, uint256 amount) external {
        balance[to] += amount;
    }
}
