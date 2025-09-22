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

contract CheckNewLottery is Script {
    function run() external {
        address factoryAddress = 0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd;
        address newLotteryAddress = 0x72ea816ACD8de1FA191263BaE0ACDfBA650551E9;
        
        console.log("=== REVISANDO NUEVA LOTERIA ===");
        console.log("Factory:", factoryAddress);
        console.log("Nueva Lottery:", newLotteryAddress);
        
        LotteryFactoryV7 factory = LotteryFactoryV7(factoryAddress);
        ILottery lottery = ILottery(newLotteryAddress);
        
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
            console.log("=== INFO DE LA NUEVA LOTERIA ===");
            console.log("Nombre:", name);
            console.log("Creador:", creator);
            console.log("Estado:", state); // 0=Open, 1=Drawing, 2=Completed, 3=Cancelled
            console.log("Precio ticket:", ticketPrice);
            console.log("Participantes:", participantCount);
            console.log("Prize Pool:", prizePool);
            console.log("Ganador:", winner);
            
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
            
            // Verificar si hay VRF pendiente
            bool hasPending = factory.hasVRFPending(newLotteryAddress);
            console.log("VRF Pendiente:", hasPending);
            
            if (state == 1) {
                console.log("WARNING: LOTERIA COLGADA EN DRAWING");
                console.log("Esto significa que Chainlink VRF no respondio");
            } else if (state == 2) {
                console.log("SUCCESS: LOTERIA COMPLETADA");
            } else if (state == 0) {
                console.log("OPEN: LOTERIA ABIERTA");
            }
            
        } catch {
            console.log("Error obteniendo info de la loteria");
        }
    }
}