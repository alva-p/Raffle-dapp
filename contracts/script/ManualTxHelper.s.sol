// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";
import {LotteryOpenV3} from "../src/lotteries/LotteryOpenV3.sol";

contract ManualTxHelper is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryV6Address = vm.envAddress("FACTORY_V6_ADDRESS");
        
        console.log("=== MANUAL TRANSACTION HELPER ===");
        console.log("Factory V6:", factoryV6Address);
        
        vm.startBroadcast(deployerPrivateKey);
        
        LotteryFactoryV6 factory = LotteryFactoryV6(factoryV6Address);
        
        // Create a new lottery for manual testing
        console.log("\n1. Creating new lottery for manual testing...");
        address lotteryAddress = factory.createLotteryOpen(
            0, // ETH
            address(0), // no token
            0.001 ether, // 0.001 ETH ticket price
            "Manual Test Lottery"
        );
        
        console.log("New Lottery Address:", lotteryAddress);
        
        // Add it as consumer automatically
        console.log("\n2. Adding as consumer...");
        // Note: You'll need to add this lottery as consumer in Chainlink dashboard
        
        LotteryOpenV3 lottery = LotteryOpenV3(lotteryAddress);
        
        // Join the lottery
        console.log("\n3. Joining lottery...");
        lottery.enter{value: 0.001 ether}();
        
        console.log("\n=== MANUAL TRANSACTION PARAMETERS ===");
        console.log("Contract Address:", lotteryAddress);
        console.log("Function: closeLottery()");
        console.log("Recommended Gas Limit: 150000");
        console.log("Recommended Gas Price: Check current network price + 10%");
        
        // Get current gas price for reference
        console.log("Current block gas price for reference:");
        
        console.log("\n=== STEPS FOR MANUAL EXECUTION ===");
        console.log("1. Add this lottery as consumer in Chainlink dashboard:");
        console.log("   - Go to https://vrf.chain.link");
        console.log("   - Subscription ID: 12478");
        console.log("   - Add consumer:", lotteryAddress);
        console.log("2. Use these settings in MetaMask:");
        console.log("   - Gas Limit: 150000 (manual override)");
        console.log("   - Gas Price: Current + 20% buffer");
        console.log("3. Call closeLottery() function");
        
        vm.stopBroadcast();
        
        console.log("\nLottery ready for manual VRF test!");
    }
}