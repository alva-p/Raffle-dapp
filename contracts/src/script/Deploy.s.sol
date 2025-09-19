// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {LotteryFactory} from "../LotteryFactory.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "forge-std/console2.sol"; // arriba, con los imports


contract DeployFactory is Script {
    function run() external {
        // --- Load env ---
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        bytes32 keyHash = vm.envBytes32("KEY_HASH");
        uint64 subId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        uint16 minConf = uint16(vm.envUint("VRF_MIN_CONF"));
        uint32 cbGas = uint32(vm.envUint("VRF_CB_GAS"));

        address owner = vm.addr(pk);

        vm.startBroadcast(pk);

        // Deploy Factory
        LotteryFactory factory = new LotteryFactory(
            owner,
            vrfCoordinator,
            keyHash,
            subId,
            minConf,
            cbGas
        );

        // Add factory as consumer to the subscription
        // (esto requiere que la wallet sea owner de esa sub en el panel)
        VRFCoordinatorV2Interface(vrfCoordinator).addConsumer(subId, address(factory));

        vm.stopBroadcast();

        console2.log("Factory deployed to:", address(factory));
    }
}
