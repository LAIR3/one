
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
