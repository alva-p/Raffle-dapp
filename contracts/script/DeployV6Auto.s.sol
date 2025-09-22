// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";

contract DeployV6Auto is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("=== DEPLOYING LOTTERY FACTORY V6 AUTO-CONSUMER ===");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);

        // 🚀 DEPLOY FACTORY V6 AUTO - CON AUTO-CONSUMER
        LotteryFactoryV6 factory = new LotteryFactoryV6();

        console.log("=== DEPLOYMENT SUCCESSFUL ===");
        console.log("Factory V6 Auto Address:", address(factory));
        
        // 🔍 VERIFICAR CONFIGURACIÓN VRF
        (address vrfCoordinator, uint64 subscriptionId, bytes32 keyHash) = factory.getVRFConfig();
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        console.log("Key Hash:");
        console.logBytes32(keyHash);
        
        console.log("=== AUTO-CONSUMER FEATURES ===");
        console.log("New lotteries will be automatically added as VRF consumers");
        console.log("No manual consumer addition needed");
        console.log("Backup manual functions available if needed");
        
        console.log("=== READY FOR PRODUCTION ===");

        vm.stopBroadcast();
    }
}