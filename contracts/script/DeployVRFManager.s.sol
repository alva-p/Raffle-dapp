// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {VRFManager} from "../src/VRFManager.sol";

contract DeployVRFManager is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey); // Derive address from private key
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        bytes32 keyHash = vm.envBytes32("KEY_HASH");
        uint64 subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        uint16 minConfirmations = 3;
        uint32 callbackGasLimit = 100000;

        vm.startBroadcast(deployerPrivateKey);

        VRFManager vrfManager = new VRFManager(
            owner, // owner
            vrfCoordinator,
            keyHash,
            subscriptionId,
            minConfirmations,
            callbackGasLimit
        );

        vm.stopBroadcast();

        // Log información importante
        console.log("=== VRFManager Deployed ===");
        console.log("Address:", address(vrfManager));
        console.log("Owner:", owner);
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        console.log("Key Hash:", vm.toString(keyHash));
        console.log("============================");

        return address(vrfManager);
    }
}