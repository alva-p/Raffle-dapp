// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract TestFactoryV6 is Script {
    
    LotteryFactoryV6 constant factory = LotteryFactoryV6(0xcF61E1aac9dfe0883268E5480719c1927625BE7E);
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("=== TESTING LOTTERY FACTORY V6 ===");
        console.log("Factory Address:", address(factory));
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 🎯 CREAR LOTERÍA DE PRUEBA (ETH)
        address lotteryAddr = factory.createLotteryOpen(
            0,  // Currency.NATIVE (ETH)
            address(0), // No token address for ETH
            0.01 ether, // Precio del ticket: 0.01 ETH
            "Loteria de Prueba MVP"
        );
        
        console.log("=== LOTTERY CREATED ===");
        console.log("Lottery Address:", lotteryAddr);
        
        // 🎯 OBTENER INFO DE LA LOTERÍA
        LotteryOpenV3 lottery = LotteryOpenV3(lotteryAddr);
        
        (
            string memory name,
            address creator,
            LotteryOpenV3.State state,
            LotteryOpenV3.Currency currency,
            address token,
            uint256 ticketPrice,
            uint256 participantCount,
            uint256 prizePool,
            address winner
        ) = lottery.getLotteryInfo();
        
        console.log("=== LOTTERY INFO ===");
        console.log("Name:", name);
        console.log("Creator:", creator);
        console.log("State:", uint256(state));
        console.log("Currency:", uint256(currency));
        console.log("Ticket Price:", ticketPrice);
        console.log("Participants:", participantCount);
        console.log("Prize Pool:", prizePool);
        
        console.log("=== TEST COMPLETED ===");
        console.log("Ready for participants to join with 0.01 ETH!");

        vm.stopBroadcast();
    }
}