// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV7} from "../src/LotteryFactoryV7.sol";

contract VerifyV7 is Script {
    function run() external {
        address factoryAddress = 0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd;
        
        console.log("=== VERIFICANDO FACTORY V7 ===");
        console.log("Factory Address:", factoryAddress);
        
        LotteryFactoryV7 factory = LotteryFactoryV7(factoryAddress);
        
        // 🔍 VERIFICAR CONFIGURACIÓN VRF
        (address vrfCoordinator, uint64 subscriptionId, bytes32 keyHash) = factory.getVRFConfig();
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        console.log("Key Hash:");
        console.logBytes32(keyHash);
        
        // 📊 VERIFICAR ESTADO
        uint256 lotteryCount = factory.getLotteryCount();
        console.log("Lottery Count:", lotteryCount);
        
        if (lotteryCount > 0) {
            console.log("=== LOTERIAS EXISTENTES ===");
            address[] memory allLotteries = factory.getAllLotteries();
            for (uint i = 0; i < allLotteries.length; i++) {
                console.log("Lottery", i, ":", allLotteries[i]);
            }
        }
        
        console.log("=== VERIFICACION COMPLETA ===");
        console.log("Para agregar como consumer en Chainlink:");
        console.log("1. Ve a https://vrf.chain.link/sepolia");
        console.log("2. Encuentra suscripcion ID:", subscriptionId);
        console.log("3. Agrega esta direccion como consumer:");
        console.log(factoryAddress);
    }
}