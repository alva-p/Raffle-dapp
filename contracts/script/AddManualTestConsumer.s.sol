// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract AddManualTestConsumer is Script {
    address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 constant SUBSCRIPTION_ID = 12478;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // The new lottery address from ManualTxHelper
        address lotteryAddress = 0x3Fb8c5cE9eDAF9292c21c1C65d4d4349b3eBe826;
        
        console.log("=== ADDING MANUAL TEST LOTTERY AS CONSUMER ===");
        console.log("Lottery Address:", lotteryAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        coordinator.addConsumer(SUBSCRIPTION_ID, lotteryAddress);
        
        console.log("Consumer added successfully!");
        console.log("\n=== READY FOR MANUAL TEST ===");
        console.log("Contract Address:", lotteryAddress);
        console.log("ABI Function: closeLottery()");
        console.log("Recommended Gas Limit: 150000");
        
        vm.stopBroadcast();
    }
}