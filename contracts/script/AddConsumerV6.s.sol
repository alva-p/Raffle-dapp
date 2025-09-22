// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract AddConsumerV6 is Script {
    address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 constant SUBSCRIPTION_ID = 12478;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryV6 = vm.envAddress("FACTORY_V6_ADDRESS");
        
        console.log("=== ADDING FACTORY V6 AS CONSUMER ===");
        console.log("Factory V6 Address:", factoryV6);
        console.log("Subscription ID:", SUBSCRIPTION_ID);
        
        vm.startBroadcast(deployerPrivateKey);
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        
        // Add Factory V6 as consumer
        coordinator.addConsumer(SUBSCRIPTION_ID, factoryV6);
        
        console.log("Factory V6 added as consumer successfully!");
        
        vm.stopBroadcast();
    }
}
