// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Script } from "forge-std/src/Script.sol";
import { BlockEstateFactory } from "../src/BlockEstateFactory.sol";
import { console } from "forge-std/src/console.sol";

/**
 * @title SetSeller
 * @notice Script to set seller status in BlockEstateFactory
 */
contract SetSeller is Script {
    function run() external {
        // Get environment variables
        address factoryAddress = vm.envAddress("FACTORY");
        address seller = vm.envAddress("SELLER");
        bool status = vm.envBool("STATUS");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address broadcaster = vm.addr(privateKey);

        // Create factory instance
        BlockEstateFactory factoryContract = BlockEstateFactory(factoryAddress);

        // Log the operation details
        console.log("\nOperation details:");
        console.log("- Broadcaster address:", broadcaster);
        console.log("- Factory address:", factoryAddress);
        console.log("- Seller address:", seller);
        console.log("- Setting status:", status);

        bool isWhitelisted = factoryContract.isWhitelistedSeller(seller);
        console.log("\nOperation result:");
        console.log("- Seller whitelisted:", isWhitelisted);

        // Start broadcasting
        vm.startBroadcast(privateKey);

        // Set seller status
        factoryContract.setSeller(seller, status);

        vm.stopBroadcast();

        // Verify the change
        isWhitelisted = factoryContract.isWhitelistedSeller(seller);
        console.log("\nOperation result:");
        console.log("- Seller whitelisted:", isWhitelisted);

        if (isWhitelisted == status) {
            console.log("Operation completed successfully");
        } else {
            console.log("Operation failed - status not updated");
        }
    }
}
