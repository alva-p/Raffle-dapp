// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../LotteryFactory.sol";

contract DeployScript is Script {
    function run() external {
        // Leer variables de entorno
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        bytes32 keyHash = vm.envBytes32("KEY_HASH");
        uint64 subId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        uint16 minConfirmations = uint16(vm.envUint("MIN_CONFIRMATIONS"));
        uint32 callbackGasLimit = uint32(vm.envUint("CALLBACK_GAS_LIMIT"));

        // El deployer es quien llama (PRIVATE_KEY)
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));

        vm.startBroadcast();

        LotteryFactory factory = new LotteryFactory(
            deployer,
            vrfCoordinator,
            keyHash,
            subId,
            minConfirmations,
            callbackGasLimit
        );

        vm.stopBroadcast();

        console.log("LotteryFactory deployed at:", address(factory));
    }
}
