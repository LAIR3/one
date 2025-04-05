// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ZeroSupplyToken (Oracle 010 Project - Contract 0)
 * @dev An ERC20 token contract with standard 18 decimals where the initial
 *      supply is zero upon deployment. Tokens can be minted later by the
 *      contract owner.
 */
contract ZeroSupplyToken is ERC20, Ownable {

    // --- Constants ---
    uint8 private constant _TOKEN_DECIMALS = 18;

    // --- Constructor ---
    /**
     * @dev Initializes the token with Name, Symbol, and sets the deployer as owner.
     *      Total supply starts at 0 as no initial mint occurs.
     * @param name_ The name of the token (e.g., "My Deferred Token").
     * @param symbol_ The symbol of the token (e.g., "MDT").
     * @param initialTokenOwner The address that will own this token contract instance
     *                          and control its minting function.
     */
    constructor(string memory name_, string memory symbol_, address initialTokenOwner)
        ERC20(name_, symbol_)       // Initialize ERC20 base contract
        Ownable(initialTokenOwner)  // Set the owner for this specific token instance
    {
        require(initialTokenOwner != address(0), "Ownable: initial owner is the zero address");
        // Intentionally empty constructor body.
        // No _mint() call here means totalSupply() starts at 0.
    }

    // --- ERC20 Overrides ---
    /**
     * @dev Returns the number of decimals used for token representation (18).
     */
    function decimals() public view virtual override returns (uint8) {
        return _TOKEN_DECIMALS;
    }

    // --- Minting Function ---
    /**
     * @dev Creates `amount` new tokens (in base units) and assigns them to `to`.
     *      Increases the total supply. Can only be called by the owner of this
     *      specific token contract instance.
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint (in the smallest unit, scaled to 18 decimals).
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount); // OpenZeppelin's internal mint function
    }
}
