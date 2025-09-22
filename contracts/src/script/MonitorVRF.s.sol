// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {LotteryFactory} from "../LotteryFactory.sol";
import {LotteryOpen} from "../lotteries/LotteryOpen.sol";

contract MonitorVRFScript is Script {
    function run() external {
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        uint64 subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        LotteryFactory factory = LotteryFactory(factoryAddress);
        
        console.log("=== VRF MONITORING ===");
        console.log("Factory Address:", factoryAddress);
        console.log("Subscription ID:", subscriptionId);
        
        // Get subscription info
        (uint96 balance, uint64 reqCount, address owner, address[] memory consumers) = coordinator.getSubscription(subscriptionId);
        
        console.log("\n=== SUBSCRIPTION INFO ===");
        console.log("Balance (LINK):", balance / 1e18, "LINK");
        console.log("Request Count:", reqCount);
        console.log("Owner:", owner);
        console.log("Consumers Count:", consumers.length);
        
        for (uint i = 0; i < consumers.length; i++) {
            console.log("Consumer", i, ":", consumers[i]);
        }
        
        // Get all lotteries
        address[] memory lotteries = factory.getAllLotteries();
        console.log("\n=== LOTTERIES INFO ===");
        console.log("Total Lotteries:", lotteries.length);
        
        if (lotteries.length > 0) {
            address lastLottery = lotteries[lotteries.length - 1];
            console.log("Last Lottery:", lastLottery);
            
            // Check if the lottery received random numbers
            LotteryOpen lottery = LotteryOpen(lastLottery);
            
            // Try to get some info about the lottery state
            console.log("Lottery Owner:", lottery.owner());
            
            // You might want to add a function to check if randomness was received
            // For now, we'll check events
        }
    }
}