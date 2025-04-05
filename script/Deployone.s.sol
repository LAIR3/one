// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/one.sol";

contract Deployone is Script {
    function run() external {
        // Start broadcasting without explicitly providing a private key.
        // Foundry will likely use the default Anvil accounts.
        vm.startBroadcast();

        // Specify the initial recipient address
        address initialRecipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        // Deploy the OneOneOracleToken contract
        OneOneOracleToken oneOneToken = new OneOneOracleToken(initialRecipient);

        // Optional: Print the deployed contract address
        console.log("OneOneOracleToken deployed to:", address(oneOneToken));

        vm.stopBroadcast();
    }
}
