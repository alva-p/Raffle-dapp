// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV6} from "../src/LotteryFactoryV6.sol";

contract ViewAllLotteries is Script {
    function run() external view {
        address factoryAddress = 0xBef1f829107Cd80f7b1f0739C0677dcCaa705B6A;
        
        console.log("=== ALL LOTTERIES FROM FACTORY V6 AUTO ===");
        console.log("Factory Address:", factoryAddress);
        
        LotteryFactoryV6 factory = LotteryFactoryV6(factoryAddress);
        
        address[] memory allLotteries = factory.getAllLotteries();
        uint256 count = allLotteries.length;
        
        console.log("Total lotteries:", count);
        
        for (uint i = 0; i < count; i++) {
            console.log("Lottery", i + 1, ":", allLotteries[i]);
        }
        
        if (count == 0) {
            console.log("No lotteries found. Create one from frontend first!");
        }
    }
}