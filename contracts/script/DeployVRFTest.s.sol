// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {VRFTest} from "../src/VRFTest.sol";

contract DeployVRFTest is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint64 subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        bytes32 keyHash = vm.envBytes32("KEY_HASH");

        vm.startBroadcast(deployerPrivateKey);

        VRFTest vrfTest = new VRFTest(
            subscriptionId,
            vrfCoordinator,
            keyHash
        );

        vm.stopBroadcast();

        return address(vrfTest);
    }
}