// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

// Interface mínima para VRF Coordinator
interface IVRFCoordinatorV2 {
    function getSubscription(uint64 subId) external view returns (
        uint96 balance,
        uint64 reqCount,
        address owner,
        address[] memory consumers
    );
}

contract DiagnoseVRF is Script {
    function run() external {
        address factoryAddress = 0x5C3Db4408FCEd621f934FEaB3F73c5F4FC86f9bd;
        address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
        uint64 subscriptionId = 12478;
        
        console.log("=== DIAGNOSTICO VRF ===");
        console.log("Factory Address:", factoryAddress);
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        
        IVRFCoordinatorV2 coordinator = IVRFCoordinatorV2(vrfCoordinator);
        
        try coordinator.getSubscription(subscriptionId) returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        ) {
            console.log("=== SUSCRIPCION INFO ===");
            console.log("Balance LINK:", balance);
            console.log("Request Count:", reqCount);
            console.log("Owner:", owner);
            console.log("Consumers Count:", consumers.length);
            
            console.log("=== CONSUMERS ===");
            bool factoryFound = false;
            for (uint i = 0; i < consumers.length; i++) {
                console.log("Consumer", i, ":", consumers[i]);
                if (consumers[i] == factoryAddress) {
                    factoryFound = true;
                }
            }
            
            if (factoryFound) {
                console.log("SUCCESS: Factory encontrada como consumer");
            } else {
                console.log("ERROR: Factory NO encontrada como consumer");
                console.log("Necesitas agregar:", factoryAddress);
            }
            
            if (balance == 0) {
                console.log("ERROR: Sin fondos LINK");
                console.log("Necesitas depositar LINK en la suscripcion");
            } else {
                console.log("SUCCESS: Hay fondos LINK disponibles");
            }
            
        } catch {
            console.log("ERROR: No se puede leer la suscripcion");
            console.log("Verifica que la subscription ID sea correcta");
        }
    }
}