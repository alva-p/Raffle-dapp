// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract InteractV6 is Script {
    
    LotteryFactoryV6 constant factory = LotteryFactoryV6(0xcF61E1aac9dfe0883268E5480719c1927625BE7E);
    LotteryOpenV3 constant testLottery = LotteryOpenV3(0xc07b9Ed881a8F8f1047A92d12749FD231d039F49);
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("=== CHAINLINK VRF VERIFICATION ===");
        console.log("Factory V6:", address(factory));
        console.log("Test Lottery:", address(testLottery));
        
        // 🔍 VERIFICAR CONFIGURACIÓN VRF
        (address vrfCoordinator, uint64 subscriptionId, bytes32 keyHash) = factory.getVRFConfig();
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        console.log("Key Hash:");
        console.logBytes32(keyHash);
        
        // 🔍 VERIFICAR ESTADO DE LA LOTERÍA
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
        ) = testLottery.getLotteryInfo();
        
        console.log("=== LOTTERY STATUS ===");
        console.log("Name:", name);
        console.log("Creator:", creator);
        console.log("State:", uint256(state), "(0=Open, 1=Drawing, 2=Completed, 3=Cancelled)");
        console.log("Ticket Price:", ticketPrice, "wei (0.01 ETH)");
        console.log("Participants:", participantCount);
        console.log("Prize Pool:", prizePool, "wei");
        
        if (winner != address(0)) {
            console.log("Winner:", winner);
        }
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 🎯 SI LA LOTERÍA ESTÁ ABIERTA, PARTICIPAR COMO PRUEBA
        if (uint256(state) == 0 && participantCount < 2) {
            console.log("=== PARTICIPATING IN LOTTERY ===");
            testLottery.enter{value: 0.01 ether}();
            console.log("Successfully participated with 0.01 ETH");
        }
        
        vm.stopBroadcast();
        
        // 🔍 VERIFICAR ESTADO DESPUÉS DE PARTICIPAR
        (, , state, , , , participantCount, prizePool, ) = testLottery.getLotteryInfo();
        console.log("=== UPDATED STATUS ===");
        console.log("Participants:", participantCount);
        console.log("Prize Pool:", prizePool, "wei");
        console.log("State:", uint256(state));
        
        if (participantCount >= 1) {
            console.log("=== READY TO START LOTTERY ===");
            console.log("You can now call closeLottery() to start VRF");
            console.log("Command: cast send", address(testLottery), '"closeLottery()"', "--rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY");
        }
    }
}