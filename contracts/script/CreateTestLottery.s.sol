// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV7} from "../src/LotteryFactoryV7.sol";

contract CreateTestLottery is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        address factoryAddress = 0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd;
        
        console.log("=== CREANDO NUEVA LOTERIA DE PRUEBA ===");
        console.log("Deployer:", deployer);
        console.log("Factory:", factoryAddress);
        
        LotteryFactoryV7 factory = LotteryFactoryV7(factoryAddress);
        
        vm.startBroadcast(deployerPrivateKey);

        // 🎯 CREAR NUEVA LOTERIA
        address newLottery = factory.createLotteryOpen(
            0, // NATIVE (ETH)
            address(0), // No token address for ETH
            0.001 ether, // 0.001 ETH por ticket
            "Prueba VRF V7" // Nombre de la lotería
        );

        console.log("=== LOTERIA CREADA EXITOSAMENTE ===");
        console.log("Nueva Lottery:", newLottery);
        
        // 📊 VERIFICAR ESTADO
        uint256 totalLotteries = factory.getLotteryCount();
        console.log("Total Lotteries:", totalLotteries);
        
        vm.stopBroadcast();
        
        console.log("=== PROXIMOS PASOS ===");
        console.log("1. Participar en la loteria:", newLottery);
        console.log("2. Usar el frontend en: http://localhost:5174/");
        console.log("3. O usar participate script");
    }
}