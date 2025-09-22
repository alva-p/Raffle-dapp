// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {LotteryFactory} from "../LotteryFactory.sol";
import {LotteryOpen} from "../lotteries/LotteryOpen.sol";

contract CompleteVRFTest is Script {
    function run() external {
        // Load env vars
        address factoryAddr = vm.envAddress("FACTORY_ADDRESS");
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        vm.startBroadcast(deployerKey);

        LotteryFactory factory = LotteryFactory(factoryAddr);

        console.log("=== PASO 1: CREAR LOTERIA ===");
        // 1. Crear una nueva LotteryOpen
        address lotteryAddr = factory.createLotteryOpen(
            LotteryOpen.Currency.NATIVE, // ETH
            address(0),                  // sin token
            0.01 ether                   // precio del ticket
        );
        console.log("Nueva Loteria creada en:", lotteryAddr);

        LotteryOpen lottery = LotteryOpen(lotteryAddr);

        console.log("\n=== PASO 2: ANADIR PARTICIPANTES ===");
        // 2. Añadir participantes
        lottery.enter{value: 0.01 ether}();
        console.log("Participante anadido:", deployer);
        
        // Verificar participantes
        address[] memory participants = lottery.getParticipants();
        console.log("Total participantes:", participants.length);

        console.log("\n=== PASO 3: CERRAR LOTERIA ===");
        // 3. Cerrar la lotería (cambiar estado a Drawing)
        console.log("Estado antes de cerrar:", uint(lottery.lotteryState()));
        lottery.closeLottery();
        console.log("Estado despues de cerrar:", uint(lottery.lotteryState()));

        console.log("\n=== PASO 4: SOLICITAR RANDOMNESS ===");
        // 4. Solicitar randomness del VRF
        uint256 requestId = factory.requestRandomness(lotteryAddr, 1);
        console.log("VRF request enviado, ID:", requestId);

        vm.stopBroadcast();

        console.log("\n=== INSTRUCCIONES ===");
        console.log("1. Espera 2-5 minutos para que Chainlink procese el VRF");
        console.log("2. Verifica los ganadores con:");
        console.log("   cast call", lotteryAddr, '"getWinners()" --rpc-url $SEPOLIA_RPC_URL');
        console.log("3. Verifica el estado final con:");
        console.log("   cast call", lotteryAddr, '"lotteryState()" --rpc-url $SEPOLIA_RPC_URL');
        console.log("   (Deberia ser 4 = Completed cuando termine)");
        
        console.log("\n=== RESUMEN ===");
        console.log("Loteria:", lotteryAddr);
        console.log("Participantes:", participants.length);
        console.log("VRF Request ID:", requestId);
        console.log("Estado actual: 3 (Drawing)");
    }
}