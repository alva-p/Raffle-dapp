// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract CheckWinner is Script {
    function run() external view {
        address lotteryAddress = 0xF3d79E99d8456EcdA71Fb577d9DcD323C91D52E7;
        
        console.log("=== CHECKING LOTTERY RESULTS ===");
        console.log("Lottery Address:", lotteryAddress);
        
        LotteryOpenV3 lottery = LotteryOpenV3(lotteryAddress);
        
        (
            string memory name,
            address creator,
            LotteryOpenV3.State state,
            ,
            ,
            uint256 ticketPrice,
            uint256 participantCount,
            uint256 prizePool,
            address winner
        ) = lottery.getLotteryInfo();
        
        console.log("\nLottery Info:");
        console.log("Name:", name);
        console.log("Creator:", creator);
        console.log("State:", uint256(state)); // 0=Open, 1=Drawing, 2=Completed, 3=Cancelled
        console.log("Ticket Price:", ticketPrice);
        console.log("Participants:", participantCount);
        console.log("Prize Pool:", prizePool);
        console.log("Winner:", winner);
        
        if (state == LotteryOpenV3.State.Completed) {
            console.log("\nSUCCESS! Lottery completed successfully!");
            console.log("Winner received:", prizePool, "wei");
        } else if (state == LotteryOpenV3.State.Drawing) {
            console.log("\nWaiting for VRF fulfillment...");
            console.log("Check Chainlink VRF dashboard for request status");
        } else if (state == LotteryOpenV3.State.Open) {
            console.log("\nLottery still open");
        }
        
        // Show participants
        address[] memory participants = lottery.getParticipants();
        console.log("\nParticipants:");
        for (uint i = 0; i < participants.length; i++) {
            console.log("Participant", i + 1, ":", participants[i]);
        }
    }
}