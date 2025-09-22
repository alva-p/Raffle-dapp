// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV7} from "../src/LotteryFactoryV7.sol";

contract DeployV7Updated is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("=== DEPLOYING LOTTERY FACTORY V7 UPDATED - 100K GAS ===");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);

        // 🚀 DEPLOY FACTORY V7 UPDATED - CON 100K GAS LIMIT
        LotteryFactoryV7 factory = new LotteryFactoryV7();

        console.log("=== DEPLOYMENT SUCCESSFUL ===");
        console.log("Factory V7 Updated Address:", address(factory));
        
        // 🔍 VERIFICAR CONFIGURACIÓN VRF
        (address vrfCoordinator, uint64 subscriptionId, bytes32 keyHash) = factory.getVRFConfig();
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        console.log("Key Hash:");
        console.logBytes32(keyHash);
        console.log("Gas Limit:", factory.CALLBACK_GAS_LIMIT());
        
        console.log("=== VRF RELAY FEATURES ===");
        console.log("Factory is the ONLY VRF consumer needed");
        console.log("Individual lotteries do NOT need to be consumers");
        console.log("Factory relays VRF responses to specific lotteries");
        console.log("Gas Limit increased to 100,000 for reliable callback");
        
        console.log("=== NEXT STEP ===");
        console.log("Replace old Factory as consumer in Chainlink:");
        console.log("OLD:", "0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd");
        console.log("NEW:", address(factory));
        
        vm.stopBroadcast();
    }
}