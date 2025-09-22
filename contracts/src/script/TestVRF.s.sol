// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {LotteryFactory} from "../LotteryFactory.sol";
import {LotteryOpen} from "../lotteries/LotteryOpen.sol";

contract TestVRFScript is Script {
    function run() external {
        // Load env vars
        address factoryAddr = vm.envAddress("FACTORY_ADDRESS");
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        vm.startBroadcast(deployerKey);

        LotteryFactory factory = LotteryFactory(factoryAddr);

        // 1. Crear una nueva LotteryOpen
        address lotteryAddr = factory.createLotteryOpen(
            LotteryOpen.Currency.NATIVE, // ETH
            address(0),                  // sin token
            0.01 ether                   // precio del ticket
        );
        console.log("=== PASO 1: LOTERIA CREADA ===");
        console.log("Nueva Loteria en:", lotteryAddr);

        LotteryOpen lottery = LotteryOpen(lotteryAddr);

        // 2. Anadir algunos participantes (tu mismo en este caso)
        console.log("=== PASO 2: ANADIR PARTICIPANTES ===");
        lottery.enter{value: 0.01 ether}();
        console.log("Participante anadido:", deployer);

        // Solo añadiremos un participante (el deployer) en este test
        // En una loteria real, otros usuarios también participarían

        // 3. Verificar participantes
        address[] memory participants = lottery.getParticipants();
        console.log("Total participantes:", participants.length);
        for (uint i = 0; i < participants.length; i++) {
            console.log("Participante", i, ":", participants[i]);
        }

        // 4. Para testing, necesitamos cambiar el estado manualmente 
        // En tu contrato productivo, necesitarías una función para cerrar la lotería
        console.log("=== PASO 3: VERIFICAR ESTADO ANTES ===");
        console.log("Estado actual:", uint(lottery.lotteryState()));

        // NOTA: Tu contrato actual no tiene una funcion para cambiar el estado a Drawing
        // Por eso el VRF falla. Necesitarias anadir una funcion como esta en LotteryBase:
        // function startDraw() external onlyCreator {
        //     require(lotteryState == State.Open, "Invalid state");
        //     lotteryState = State.Drawing;
        // }

        console.log("=== PROBLEMA IDENTIFICADO ===");
        console.log("El contrato necesita estar en estado 'Drawing' (3) para recibir el VRF");
        console.log("Pero tu contrato no tiene una funcion publica para cambiar el estado");
        console.log("Estado actual: 1 (Open)");
        console.log("Estado necesario: 3 (Drawing)");

        // 5. Intentar el request de randomness (fallara porque el estado no es correcto)
        console.log("=== PASO 4: INTENTAR VRF REQUEST ===");
        try factory.requestRandomness(lotteryAddr, 1) {
            console.log("VRF request enviado (pero el callback fallara)");
        } catch {
            console.log("VRF request fallo");
        }

        vm.stopBroadcast();

        console.log("=== RESUMEN ===");
        console.log("1. OK Loteria creada exitosamente");
        console.log("2. OK Participantes anadidos");
        console.log("3. ERROR No se puede cambiar estado a Drawing");
        console.log("4. ERROR El callback VRF falla por estado incorrecto");
        
        console.log("=== SOLUCION REQUERIDA ===");
        console.log("Necesitas anadir una funcion en LotteryBase o LotteryOpen:");
        console.log("function closeLottery() external onlyCreator {");
        console.log("    require(lotteryState == State.Open);");
        console.log("    lotteryState = State.Drawing;");
        console.log("}");
    }
}