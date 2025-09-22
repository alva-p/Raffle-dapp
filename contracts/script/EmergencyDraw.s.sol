// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {LotteryFactoryV7} from "../src/LotteryFactoryV7.sol";

contract EmergencyDraw is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryAddress = 0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd;
        address newLotteryAddress = 0x72ea816ACD8de1FA191263BaE0ACDfBA650551E9;
        
        console.log("=== EMERGENCY DRAW ===");
        console.log("Lottery:", newLotteryAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Llamar al emergency draw de la lotería
        (bool success, ) = newLotteryAddress.call(
            abi.encodeWithSignature("emergencyDrawWinner()")
        );
        
        if (success) {
            console.log("SUCCESS: Emergency draw ejecutado");
        } else {
            console.log("ERROR: Emergency draw fallo");
        }
        
        vm.stopBroadcast();
        
        // Verificar resultado
        (bool infoSuccess, bytes memory data) = newLotteryAddress.staticcall(
            abi.encodeWithSignature("getLotteryInfo()")
        );
        
        if (infoSuccess) {
            (,, uint8 state,,, uint256 ticketPrice, uint256 participantCount, uint256 prizePool, address winner) = 
                abi.decode(data, (string, address, uint8, uint8, address, uint256, uint256, uint256, address));
            
            console.log("=== RESULTADO ===");
            console.log("Estado:", state);
            console.log("Participantes:", participantCount);
            console.log("Prize Pool:", prizePool);
            console.log("Ganador:", winner);
        }
    }
}