// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV7} from "../src/LotteryFactoryV7.sol";

interface ILottery {
    function getLotteryInfo() external view returns (
        string memory name,
        address creator,
        uint8 state,
        uint8 currency,
        address token,
        uint256 ticketPrice,
        uint256 participantCount,
        uint256 prizePool,
        address winner
    );
    function getParticipants() external view returns (address[] memory);
}

contract CheckLatestLottery is Script {
    function run() external {
        address factoryAddress = 0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd;
        address latestLotteryAddress = 0x24467ffD4547bA99988Eb386Dca38CD0c8E7814f;
        
        console.log("=== VERIFICANDO ULTIMA LOTERIA ===");
        console.log("Factory:", factoryAddress);
        console.log("Latest Lottery:", latestLotteryAddress);
        
        LotteryFactoryV7 factory = LotteryFactoryV7(factoryAddress);
        ILottery lottery = ILottery(latestLotteryAddress);
        
        // Verificar todas las loterías en factory
        uint256 totalLotteries = factory.getLotteryCount();
        console.log("Total Lotteries in Factory:", totalLotteries);
        
        address[] memory allLotteries = factory.getAllLotteries();
        for (uint i = 0; i < allLotteries.length; i++) {
            console.log("Lottery", i, ":", allLotteries[i]);
        }
        
        // Verificar si esta lotería está en la factory
        bool isFromFactory = factory.isLotteryFromFactory(latestLotteryAddress);
        console.log("Is from Factory:", isFromFactory);
        
        // Verificar VRF status
        bool hasPending = factory.hasVRFPending(latestLotteryAddress);
        console.log("Has VRF Pending:", hasPending);
        
        try lottery.getLotteryInfo() returns (
            string memory name,
            address creator,
            uint8 state,
            uint8 currency,
            address token,
            uint256 ticketPrice,
            uint256 participantCount,
            uint256 prizePool,
            address winner
        ) {
            console.log("=== ESTADO ACTUAL ===");
            console.log("Nombre:", name);
            console.log("Estado:", state);
            console.log("Participantes:", participantCount);
            console.log("Prize Pool:", prizePool);
            console.log("Ganador:", winner);
            
            if (state == 0) console.log("STATUS: OPEN - Abierta");
            if (state == 1) console.log("STATUS: DRAWING - Sorteando");
            if (state == 2) console.log("STATUS: COMPLETED - Completada");
            if (state == 3) console.log("STATUS: CANCELLED - Cancelada");
            
            if (participantCount > 0) {
                try lottery.getParticipants() returns (address[] memory participants) {
                    console.log("=== PARTICIPANTES ===");
                    for (uint i = 0; i < participants.length; i++) {
                        console.log("Participante", i, ":", participants[i]);
                    }
                } catch {
                    console.log("Error obteniendo participantes");
                }
            }
            
        } catch {
            console.log("ERROR: No se puede obtener info de la loteria");
        }
    }
}