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
    function hasVRFPending() external view returns (bool);
}

contract CheckLotteryV7 is Script {
    function run() external {
        address factoryAddress = 0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd;
        address lotteryAddress = 0xCcb9bfcfbf07b1774944faC3B8d7900D7A4d2A68;
        
        console.log("=== REVISANDO LOTERIA EXISTENTE ===");
        console.log("Factory:", factoryAddress);
        console.log("Lottery:", lotteryAddress);
        
        LotteryFactoryV7 factory = LotteryFactoryV7(factoryAddress);
        ILottery lottery = ILottery(lotteryAddress);
        
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
            console.log("=== INFO DE LA LOTERIA ===");
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
            bool hasPending = factory.hasVRFPending(lotteryAddress);
            console.log("VRF Pendiente:", hasPending);
            
        } catch {
            console.log("Error obteniendo info de la loteria");
        }
        
        console.log("=== ESTADOS POSIBLES ===");
        console.log("0 = Open (Abierta)");
        console.log("1 = Drawing (Sorteando)");
        console.log("2 = Completed (Completada)");
        console.log("3 = Cancelled (Cancelada)");
    }
}