// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {LotteryFactory} from "../LotteryFactory.sol";


contract Deploy is Script {
    function run() external {
        // Setea estos antes (pueden venir de env vars):
        address owner = vm.envAddress("OWNER");
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        bytes32 keyHash = vm.envBytes32("VRF_KEY_HASH");
        uint64 subId = uint64(vm.envUint("VRF_SUB_ID"));
        uint16 minConf = uint16(vm.envUint("VRF_MIN_CONF"));
        uint32 cbGas = uint32(vm.envUint("VRF_CB_GAS"));

        vm.startBroadcast();
        new LotteryFactory(owner, vrfCoordinator, keyHash, subId, minConf, cbGas);
        vm.stopBroadcast();
    }
}
