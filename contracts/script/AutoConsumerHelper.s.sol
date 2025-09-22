// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract AutoConsumerHelper is Script {
    address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 constant SUBSCRIPTION_ID = 12478;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryV6Address = vm.envAddress("FACTORY_V6_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        LotteryFactoryV6 factory = LotteryFactoryV6(factoryV6Address);
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        
        // Obtener todas las loterías actuales
        address[] memory allLotteries = factory.getAllLotteries();
        
        console.log("=== AUTO CONSUMER HELPER ===");
        console.log("Total lotteries found:", allLotteries.length);
        
        // Agregar todas las loterías como consumers
        for (uint i = 0; i < allLotteries.length; i++) {
            address lotteryAddr = allLotteries[i];
            console.log("Adding lottery as consumer:", lotteryAddr);
            
            try coordinator.addConsumer(SUBSCRIPTION_ID, lotteryAddr) {
                console.log("Added successfully");
            } catch {
                console.log("Already added or failed");
            }
        }
        
        console.log("\n=== NEXT STEPS FOR FRONTEND ===");
        console.log("1. Refresh the frontend page");
        console.log("2. Create a new lottery");
        console.log("3. The new lottery will need to be manually added as consumer");
        console.log("4. Or run this script again after creating");
        
        vm.stopBroadcast();
    }
}