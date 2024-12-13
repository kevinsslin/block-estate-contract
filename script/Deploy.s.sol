// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Script } from "forge-std/src/Script.sol";
import { BlockEstateFactory } from "../src/BlockEstateFactory.sol";
import { console } from "forge-std/src/console.sol";

contract Deploy is Script {
    function run() external returns (BlockEstateFactory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        BlockEstateFactory factory = new BlockEstateFactory();
        console.log("Factory deployed at:", address(factory));

        vm.stopBroadcast();
        return factory;
    }
}
