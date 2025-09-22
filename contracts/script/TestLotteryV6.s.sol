// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract TestLotteryV6 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryV6Address = vm.envAddress("FACTORY_V6_ADDRESS");
        
        console.log("=== TESTING LOTTERY V6 (GAS OPTIMIZED) ===");
        console.log("Factory Address:", factoryV6Address);
        
        vm.startBroadcast(deployerPrivateKey);
        
        LotteryFactoryV6 factory = LotteryFactoryV6(factoryV6Address);
        
        // 1. Create lottery
        console.log("\n1. Creating lottery...");
        address lotteryAddress = factory.createLotteryOpen(
            0, // ETH
            address(0), // no token
            0.001 ether, // 0.001 ETH ticket price (reduced for testing)
            "Test Lottery V6 Optimized"
        );
        
        console.log("Lottery created at:", lotteryAddress);
        
        LotteryOpenV3 lottery = LotteryOpenV3(lotteryAddress);
        
        // 2. Join lottery
        console.log("\n2. Joining lottery with 0.001 ETH...");
        lottery.enter{value: 0.001 ether}();
        
        // 3. Get lottery info
        console.log("\n3. Lottery info:");
        (, , LotteryOpenV3.State state, , , uint256 ticketPrice, uint256 participantCount, uint256 prizePool,) = lottery.getLotteryInfo();
        
        console.log("State:", uint256(state));
        console.log("Ticket Price:", ticketPrice);
        console.log("Participants:", participantCount);
        console.log("Prize Pool:", prizePool);
        
        console.log("\n=== READY FOR VRF TEST ===");
        console.log("Next step: Call closeLottery() to trigger VRF");
        console.log("Lottery Address:", lotteryAddress);
        
        vm.stopBroadcast();
    }
}