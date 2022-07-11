// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DevToken is ERC20{
    constructor(uint256 totalSupply) ERC20("DevToken", "DVT"){
        _mint(msg.sender, totalSupply);
    }
}