// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract TestAutoFlow is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryAddress = 0xBef1f829107Cd80f7b1f0739C0677dcCaa705B6A;
        
        console.log("=== TESTING FULL AUTO-FLOW ===");
        console.log("Factory Auto Address:", factoryAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        LotteryFactoryV6 factory = LotteryFactoryV6(factoryAddress);
        
        // 1. Create lottery (should auto-add as consumer)
        console.log("\n1. Creating lottery with auto-consumer...");
        address lotteryAddress = factory.createLotteryOpen(
            0, // ETH
            address(0), // no token
            0.001 ether, // 0.001 ETH ticket price
            "Auto-Consumer Test Lottery"
        );
        
        console.log("Lottery created at:", lotteryAddress);
        console.log("Consumer should be automatically added!");
        
        LotteryOpenV3 lottery = LotteryOpenV3(lotteryAddress);
        
        // 2. Join lottery
        console.log("\n2. Joining lottery...");
        lottery.enter{value: 0.001 ether}();
        
        // 3. Get lottery info
        (, , LotteryOpenV3.State state, , , uint256 ticketPrice, uint256 participantCount, uint256 prizePool, address winner) = lottery.getLotteryInfo();
        
        console.log("\n3. Lottery info:");
        console.log("State:", uint256(state));
        console.log("Ticket Price:", ticketPrice);
        console.log("Participants:", participantCount);
        console.log("Prize Pool:", prizePool);
        
        // 4. Test VRF (should work immediately since it's auto-consumer)
        console.log("\n4. Testing VRF (auto-consumer should work)...");
        lottery.closeLottery();
        
        console.log("\n=== AUTO-FLOW TEST COMPLETE ===");
        console.log("Lottery Address:", lotteryAddress);
        console.log("VRF request sent automatically!");
        console.log("Check results in a few minutes with CheckWinner script");
        
        vm.stopBroadcast();
    }
}