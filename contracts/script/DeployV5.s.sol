// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV5} from "../src/LotteryFactoryV5.sol";

contract DeployV5 is Script {
    function run() external {
        vm.startBroadcast();

        // 🚀 DEPLOY FACTORY V5 - MVP DIRECTO
        LotteryFactoryV5 factory = new LotteryFactoryV5();

        console.log("=== FACTORY V5 DEPLOYED ===");
        console.log("FactoryV5 Address:", address(factory));

        vm.stopBroadcast();
    }
}