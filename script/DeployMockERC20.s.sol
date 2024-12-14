// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Script } from "forge-std/src/Script.sol";
import { MockERC20 } from "../src/mocks/MockERC20.sol";
import { console } from "forge-std/src/console.sol";

contract Deploy is Script {
    function run() external returns (MockERC20) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address deployer = vm.addr(deployerPrivateKey);
        MockERC20 mockERC20 = new MockERC20("MockERC20", "MRC20", 18);
        console.log("MockERC20 deployed at:", address(mockERC20));

        // mint for deployer
        mockERC20.mint(deployer, 1e8 * 1e18);
        console.log("MockERC20 minted for deployer:", mockERC20.balanceOf(deployer));

        vm.stopBroadcast();
        return mockERC20;
    }
}
