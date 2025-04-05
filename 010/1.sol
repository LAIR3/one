
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OneSupplyToken77 (Oracle 010 Project - Contract 1)
 * @dev An ERC20 token contract with 77 decimals. Exactly 1 whole token is
 *      minted upon deployment to the initial owner. Further minting is
 *      controlled by the owner of this token instance.
 * @notice WARNING: 77 decimals is the maximum feasible to represent >= 1 whole
 *         token using uint256. 10**77 < type(uint256).max < 2 * 10**77.
 *         Minting significantly more tokens may lead to overflow.
 *         High decimal counts might cause display issues in wallets/interfaces.
 */
contract OneSupplyToken77 is ERC20, Ownable {

    // --- Constants ---
    uint8 private constant _TOKEN_DECIMALS = 77;
    uint256 private constant _ONE_WHOLE_TOKEN_BASE_UNITS = 10 ** uint256(_TOKEN_DECIMALS); // 1e77

    // --- Constructor ---
    /**
     * @dev Initializes the token with Name, Symbol, Owner, and mints exactly 1
     *      whole token (1e77 base units) to the initial owner.
     * @param name_ The name of the token (e.g., "ONE Unit Token").
     * @param symbol_ The symbol of the token (e.g., "ONEU").
     * @param initialTokenOwner The address that will own this token contract instance
     *                          and receive the initial supply / control minting.
     */
    constructor(string memory name_, string memory symbol_, address initialTokenOwner)
        ERC20(name_, symbol_)       // Initialize ERC20 base contract
        Ownable(initialTokenOwner)  // Set the owner for this specific token instance
    {
        require(initialTokenOwner != address(0), "Ownable: initial owner is the zero address");

        // Mint exactly one whole token (10^77 base units)
        _mint(initialTokenOwner, _ONE_WHOLE_TOKEN_BASE_UNITS);
    }

    // --- ERC20 Overrides ---
    /**
     * @dev Returns the number of decimals used for token representation (77).
     */
    function decimals() public view virtual override returns (uint8) {
        return _TOKEN_DECIMALS;
    }

    // --- Minting Function ---
    /**
     * @dev Creates `amount` new tokens (in base units) and assigns them to `to`.
     *      Increases the total supply. Can only be called by the owner of this
     *      specific token contract instance.
     * @notice Be extremely cautious with the amount to prevent exceeding uint256 limits
     *         when added to the existing total supply (which starts at 1e77).
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint (in the smallest unit, scaled to 77 decimals).
     */
    function mint(address to, uint256 amount) public onlyOwner {
        // Consider adding require(totalSupply() + amount <= type(uint256).max) if large mints are expected
        // Although OZ _mint >=0.8 has checks, an explicit pre-check might be clearer given the high decimals.
        _mint(to, amount);
    }
}
