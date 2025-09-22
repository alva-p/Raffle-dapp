// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract AddFactoryV6AutoConsumer is Script {
    address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 constant SUBSCRIPTION_ID = 12478;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryV6Auto = 0xBef1f829107Cd80f7b1f0739C0677dcCaa705B6A;
        
        console.log("=== ADDING FACTORY V6 AUTO AS CONSUMER ===");
        console.log("Factory V6 Auto Address:", factoryV6Auto);
        
        vm.startBroadcast(deployerPrivateKey);
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        coordinator.addConsumer(SUBSCRIPTION_ID, factoryV6Auto);
        
        console.log("Factory V6 Auto added as consumer successfully!");
        console.log("Now all new lotteries will be auto-added as consumers!");
        
        vm.stopBroadcast();
    }
}