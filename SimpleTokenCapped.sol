// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract DevToken is ERC20Capped, Ownable  {
    
    constructor(uint256 cap) ERC20("DevToken", "DVT") ERC20Capped(cap) {
    }

    modifier onlyAuthorized() {
        require(owner() == msg.sender);
        _;  
    }

    function issueToken() public onlyAuthorized {
        _mint(msg.sender, 100000 * 10 ** 18);
    }

    function mint(address to, uint amount) external onlyAuthorized {
        _mint(to, amount);
    }

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }

}
