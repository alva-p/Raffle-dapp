// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract AddSpecificLottery is Script {
    address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 constant SUBSCRIPTION_ID = 12478;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // La lotería que falló en el test anterior
        address lotteryAddress = 0x52a11E7C4e5ddFd747C22be24B69283fAf0d5eE9;
        
        console.log("=== ADDING SPECIFIC LOTTERY AS CONSUMER ===");
        console.log("Lottery Address:", lotteryAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        VRFCoordinatorV2Interface coordinator = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        coordinator.addConsumer(SUBSCRIPTION_ID, lotteryAddress);
        
        console.log("Specific lottery added as consumer successfully!");
        console.log("Now you can test VRF from frontend!");
        
        vm.stopBroadcast();
    }
}