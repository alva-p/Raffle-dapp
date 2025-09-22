// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {LotteryFactory} from "../LotteryFactory.sol";
import {LotteryOpen} from "../lotteries/LotteryOpen.sol";

contract InteractScript is Script {
    function run() external {
        // Load env vars
        address factoryAddr = vm.envAddress("FACTORY_ADDRESS");
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        LotteryFactory factory = LotteryFactory(factoryAddr);

        // Crear una nueva LotteryOpen
        address lottery = factory.createLotteryOpen(
            LotteryOpen.Currency.NATIVE, // ETH
            address(0),                  // sin token
            0.01 ether                   // precio del ticket
        );
        console.log("New Lottery deployed at:", lottery);

        // (Opcional: pedir randomness si ya configuraste VRF)
        uint256 requestId = factory.requestRandomness(lottery, 1);
        console.log("Randomness requested, requestId:", requestId);

        vm.stopBroadcast();
    }
}
