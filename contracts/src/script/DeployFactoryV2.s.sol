// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../LotteryFactory.sol";

contract DeployFactoryV2 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying Factory V2 with account:", deployer);
        console.log("Account balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Factory V2 con soporte para loterías privadas
        LotteryFactory factoryV2 = new LotteryFactory(
            deployer, // owner
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, // VRF Coordinator V2 (Sepolia)
            0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // Key Hash
            12478, // Subscription ID
            3, // Request confirmations
            100000 // Callback gas limit
        );

        console.log("Factory V2 deployed to:", address(factoryV2));

        vm.stopBroadcast();
    }
}