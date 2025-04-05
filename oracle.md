"Oracle 010 Project"

    ZeroSupplyToken.sol: An ERC20 token with 18 decimals, mintable by the owner, starting with zero initial supply

    OneSupplyToken77.sol: An ERC20 token with 77 decimals, mintable by the owner, starting with exactly one whole token initial supply (maximum feasible decimals for >=1 whole token)

    OracleFactory010.sol: A factory contract (controlled by its owner) capable of deploying new instances of either ZeroSupplyToken or OneSupplyToken77

Make sure to save these in the same directory or configure your development environment (like Foundry or Hardhat) to handle the imports correctly.

# ZeroSupplyToken.sol (Contract 0)
```sol      
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
```

# OneSupplyToken77.sol (Contract 1)
```sol      
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

# OracleFactory010.sol (Factory Contract)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ZeroSupplyToken.sol";    // Import Contract 0 template
import "./OneSupplyToken77.sol";   // Import Contract 1 template

/**
 * @title OracleFactory010 (Oracle 010 Project - Factory)
 * @dev A factory contract capable of deploying new instances of either
 *      `ZeroSupplyToken` (0 initial supply, 18 decimals) or
 *      `OneSupplyToken77` (1 initial supply, 77 decimals).
 *      Deployment operations are restricted to the owner of this factory contract.
 */
contract OracleFactory010 is Ownable {

    // --- State Variables ---
    address[] public deployedZeroSupplyTokens;
    address[] public deployedOneSupplyTokens;

    // --- Events ---
    event ZeroSupplyTokenDeployed(
        address indexed newTokenAddress,
        string name,
        string symbol,
        address indexed tokenOwner
    );

    event OneSupplyTokenDeployed(
        address indexed newTokenAddress,
        string name,
        string symbol,
        address indexed tokenOwner
    );

    // --- Constructor ---
    /**
     * @dev Initializes the factory contract and sets the deployer as the owner.
     */
    constructor() Ownable(msg.sender) {
        // Factory owner is set via Ownable constructor
    }

    // --- Factory Functions ---

    /**
     * @notice Deploys a new instance of ZeroSupplyToken (18 decimals, 0 initial supply).
     * @dev Only the factory owner can call this function.
     * @param name The name for the new token.
     * @param symbol The symbol for the new token.
     * @param tokenOwner The address designated to own the newly deployed token contract
     *                   and control its minting.
     * @return The address of the newly deployed ZeroSupplyToken contract.
     */
    function deployZeroSupplyToken(
        string memory name,
        string memory symbol,
        address tokenOwner
    )
        external
        onlyOwner // Restrict deployment to factory owner
        returns (address)
    {
        require(tokenOwner != address(0), "Factory: Token owner cannot be zero address");

        // Deploy the new contract using the template
        ZeroSupplyToken newToken = new ZeroSupplyToken(name, symbol, tokenOwner);
        address newTokenAddress = address(newToken);

        // Store address and emit event
        deployedZeroSupplyTokens.push(newTokenAddress);
        emit ZeroSupplyTokenDeployed(newTokenAddress, name, symbol, tokenOwner);

        return newTokenAddress;
    }

    /**
     * @notice Deploys a new instance of OneSupplyToken77 (77 decimals, 1 initial supply).
     * @dev Only the factory owner can call this function.
     * @param name The name for the new token.
     * @param symbol The symbol for the new token.
     * @param tokenOwner The address designated to own the newly deployed token contract,
     *                   receive its initial supply, and control its minting.
     * @return The address of the newly deployed OneSupplyToken77 contract.
     */
    function deployOneSupplyToken(
        string memory name,
        string memory symbol,
        address tokenOwner
    )
        external
        onlyOwner // Restrict deployment to factory owner
        returns (address)
    {
        require(tokenOwner != address(0), "Factory: Token owner cannot be zero address");

        // Deploy the new contract using the template
        OneSupplyToken77 newToken = new OneSupplyToken77(name, symbol, tokenOwner);
        address newTokenAddress = address(newToken);

        // Store address and emit event
        deployedOneSupplyTokens.push(newTokenAddress);
        emit OneSupplyTokenDeployed(newTokenAddress, name, symbol, tokenOwner);

        return newTokenAddress;
    }

    // --- Getter Functions ---

    /**
     * @dev Returns the number of ZeroSupplyToken contracts deployed by this factory.
     */
    function getDeployedZeroSupplyTokenCount() external view returns (uint256) {
        return deployedZeroSupplyTokens.length;
    }

    /**
     * @dev Returns the number of OneSupplyToken77 contracts deployed by this factory.
     */
    function getDeployedOneSupplyTokenCount() external view returns (uint256) {
        return deployedOneSupplyTokens.length;
    }
}

```
