// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract AddConsumerScript is Script {
    function run() external {
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        uint64 subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        address newFactoryAddress = vm.envAddress("FACTORY_ADDRESS");
        
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerKey);
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        
        // Add the new factory as consumer
        coordinator.addConsumer(subscriptionId, newFactoryAddress);
        console.log("Added new factory as consumer:", newFactoryAddress);
        console.log("Subscription ID:", subscriptionId);
        
        vm.stopBroadcast();
    }
}