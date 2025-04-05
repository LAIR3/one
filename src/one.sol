
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Oracle is ERC20, Ownable {
    uint8 private constant _DECIMALS = 77;
    uint256 private constant ONE_UNIT = 10 ** uint256(_DECIMALS);

    constructor(address initialRecipient) ERC20("ONE", "ONE") Ownable(msg.sender) {
        // Mint one token with 77 decimal positions to the deployer or specified recipient
        _mint(initialRecipient, ONE_UNIT);
    }

    function decimals() public view virtual override returns (uint8) {
        return _DECIMALS;
    }

    // Optional: oracle-based functionality placeholder
    function updateOracleData(uint256 /*data*/) external onlyOwner {
        // Oracle one logic here
    }
}
