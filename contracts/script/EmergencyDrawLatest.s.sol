// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

contract EmergencyDrawLatest is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address latestLotteryAddress = 0x24467ffD4547bA99988Eb386Dca38CD0c8E7814f;
        
        console.log("=== EMERGENCY DRAW LATEST LOTTERY ===");
        console.log("Lottery:", latestLotteryAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Llamar al emergency draw
        (bool success, ) = latestLotteryAddress.call(
            abi.encodeWithSignature("emergencyDrawWinner()")
        );
        
        if (success) {
            console.log("SUCCESS: Emergency draw ejecutado");
        } else {
            console.log("ERROR: Emergency draw fallo");
        }
        
        vm.stopBroadcast();
        
        // Verificar resultado
        (bool infoSuccess, bytes memory data) = latestLotteryAddress.staticcall(
            abi.encodeWithSignature("getLotteryInfo()")
        );
        
        if (infoSuccess) {
            (,, uint8 state,,,, uint256 participantCount, uint256 prizePool, address winner) = 
                abi.decode(data, (string, address, uint8, uint8, address, uint256, uint256, uint256, address));
            
            console.log("=== RESULTADO FINAL ===");
            console.log("Estado:", state);
            console.log("Participantes:", participantCount);
            console.log("Prize Pool:", prizePool);
            console.log("Ganador:", winner);
            
            if (state == 2) {
                console.log("SUCCESS: Loteria completada con ganador!");
            }
        }
    }
}