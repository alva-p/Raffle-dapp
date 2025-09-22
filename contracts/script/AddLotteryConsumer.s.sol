// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract AddLotteryConsumer is Script {
    address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 constant SUBSCRIPTION_ID = 12478;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // The lottery address from the previous test
        address lotteryAddress = 0xF3d79E99d8456EcdA71Fb577d9DcD323C91D52E7;
        
        console.log("=== ADDING LOTTERY AS CONSUMER ===");
        console.log("Lottery Address:", lotteryAddress);
        console.log("Subscription ID:", SUBSCRIPTION_ID);
        
        vm.startBroadcast(deployerPrivateKey);
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        
        // Add lottery as consumer
        coordinator.addConsumer(SUBSCRIPTION_ID, lotteryAddress);
        
        console.log("Lottery added as consumer successfully!");
        
        // Now test the VRF
        console.log("\n=== TESTING VRF ===");
        LotteryOpenV3 lottery = LotteryOpenV3(lotteryAddress);
        
        console.log("Closing lottery to trigger VRF...");
        lottery.closeLottery();
        
        console.log("VRF request sent! Check Chainlink dashboard for fulfillment.");
        
        vm.stopBroadcast();
    }
}