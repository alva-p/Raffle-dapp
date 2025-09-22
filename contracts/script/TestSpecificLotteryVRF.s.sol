// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract TestSpecificLotteryVRF is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address lotteryAddress = 0x52a11E7C4e5ddFd747C22be24B69283fAf0d5eE9;
        
        console.log("=== TESTING VRF ON SPECIFIC LOTTERY ===");
        console.log("Lottery Address:", lotteryAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        LotteryOpenV3 lottery = LotteryOpenV3(lotteryAddress);
        
        // Verificar estado actual
        (, , LotteryOpenV3.State state, , , uint256 ticketPrice, uint256 participantCount, uint256 prizePool, address winner) = lottery.getLotteryInfo();
        
        console.log("Current State:", uint256(state));
        console.log("Participants:", participantCount);
        console.log("Prize Pool:", prizePool);
        
        if (state == LotteryOpenV3.State.Open && participantCount > 0) {
            console.log("Starting VRF lottery draw...");
            lottery.closeLottery();
            console.log("VRF request sent successfully!");
        } else {
            console.log("Cannot start VRF - wrong state or no participants");
        }
        
        vm.stopBroadcast();
    }
}