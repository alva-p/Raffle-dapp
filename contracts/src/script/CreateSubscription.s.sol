// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract CreateSubscriptionScript is Script {
    function run() external {
        // Sepolia addresses
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        address linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789; // LINK on Sepolia
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");
        
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerKey);
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        
        // 1. Create subscription
        uint64 subId = coordinator.createSubscription();
        console.log("Created subscription ID:", subId);
        
        // 2. Add consumer (your factory contract)
        coordinator.addConsumer(subId, factoryAddress);
        console.log("Added consumer:", factoryAddress);
        
        // 3. Fund subscription with LINK (you need to have LINK tokens first)
        LinkTokenInterface link = LinkTokenInterface(linkToken);
        uint256 linkBalance = link.balanceOf(msg.sender);
        console.log("Your LINK balance:", linkBalance);
        
        if (linkBalance > 0) {
            // Fund with 2 LINK tokens (adjust as needed)
            uint256 fundAmount = 2 ether; // 2 LINK
            if (linkBalance >= fundAmount) {
                link.transferAndCall(vrfCoordinator, fundAmount, abi.encode(subId));
                console.log("Funded subscription with:", fundAmount);
            } else {
                console.log("Not enough LINK to fund. Please get LINK from faucets.chain.link");
            }
        } else {
            console.log("No LINK tokens found. Please get LINK from faucets.chain.link");
        }
        
        vm.stopBroadcast();
        
        console.log("=====================================");
        console.log("UPDATE YOUR .env FILE:");
        console.log("SUBSCRIPTION_ID=", subId);
        console.log("=====================================");
    }
}