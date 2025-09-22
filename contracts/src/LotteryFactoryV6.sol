// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LotteryOpenV3} from "./lotteries/LotteryOpenV3.sol";
import {Errors} from "./libs/Errors.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

/// @title LotteryFactoryV6 - ULTRA OPTIMIZADO CON CREATE2
/// @notice Factory optimizada con CREATE2 para direcciones determinísticas y menor gas
contract LotteryFactoryV6 is Ownable {
    
    // 🎯 VRF CONFIG DIRECTO - CONSTANTES OPTIMIZADAS
    address public constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // Sepolia
    uint64 public constant SUBSCRIPTION_ID = 12478;
    uint32 public constant CALLBACK_GAS_LIMIT = 50000; // 🔥 OPTIMIZADO PARA MENOS GAS
    
    // 🎯 VRF COORDINATOR INTERFACE
    VRFCoordinatorV2Interface private immutable COORDINATOR;
    
    bytes32 public constant KEY_HASH = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    
    // 🎯 STORAGE OPTIMIZADO
    address[] public allLotteries;
    mapping(address => bool) public isLotteryFromFactory;
    uint256 private _lotteryCounter; // Para CREATE2 determinístico

    event LotteryCreated(address indexed lottery, address indexed creator, uint256 ticketPrice, string name);
    event ConsumerAdded(address indexed lottery, bool success);

    constructor() Ownable(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(VRF_COORDINATOR);
    }

    // 🎯 CREAR LOTERÍA CON CREATE2 - ULTRA OPTIMIZADO
    function createLotteryOpen(
        uint8 currency,
        address token,
        uint256 ticketPrice,
        string calldata lotteryName
    ) external returns (address) {
        if (ticketPrice == 0) revert Errors.InvalidInput();
        if (currency == 1 && token == address(0)) revert Errors.InvalidInput();
        
        // 🚀 CREATE2 para direcciones determinísticas (ahorra gas en frontend)
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, _lotteryCounter++));
        
        LotteryOpenV3 newLottery = new LotteryOpenV3{salt: salt}(
            msg.sender,
            VRF_COORDINATOR,
            SUBSCRIPTION_ID,
            KEY_HASH,
            CALLBACK_GAS_LIMIT,
            LotteryOpenV3.Currency(currency),
            token,
            ticketPrice,
            lotteryName
        );

        address lotteryAddress = address(newLottery);
        allLotteries.push(lotteryAddress);
        isLotteryFromFactory[lotteryAddress] = true;

        // 🚀 AUTO-ADD AS VRF CONSUMER
        bool consumerAdded = false;
        try COORDINATOR.addConsumer(SUBSCRIPTION_ID, lotteryAddress) {
            consumerAdded = true;
        } catch {
            // If adding consumer fails, continue but emit event
            consumerAdded = false;
        }
        
        emit LotteryCreated(lotteryAddress, msg.sender, ticketPrice, lotteryName);
        emit ConsumerAdded(lotteryAddress, consumerAdded);
        
        return lotteryAddress;
    }

    // 🎯 PREDECIR DIRECCIÓN ANTES DE CREAR (ÚTIL PARA FRONTEND)
    function predictLotteryAddress(address creator) external view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(creator, _lotteryCounter));
        
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(type(LotteryOpenV3).creationCode)
            )
        );
        
        return address(uint160(uint256(hash)));
    }

    // 🎯 GETTERS OPTIMIZADOS
    function getAllLotteries() external view returns (address[] memory) {
        return allLotteries;
    }

    function getLotteryCount() external view returns (uint256) {
        return allLotteries.length;
    }
    
    function getNextLotteryCounter() external view returns (uint256) {
        return _lotteryCounter;
    }

    // 🎯 MANUAL CONSUMER ADDITION (BACKUP)
    function addLotteryAsConsumer(address lotteryAddress) external onlyOwner {
        require(isLotteryFromFactory[lotteryAddress], "Not from this factory");
        COORDINATOR.addConsumer(SUBSCRIPTION_ID, lotteryAddress);
        emit ConsumerAdded(lotteryAddress, true);
    }

    // 🎯 BATCH ADD CONSUMERS (UTILITY)
    function addMultipleConsumers(address[] calldata lotteryAddresses) external onlyOwner {
        for (uint256 i = 0; i < lotteryAddresses.length; i++) {
            if (isLotteryFromFactory[lotteryAddresses[i]]) {
                try COORDINATOR.addConsumer(SUBSCRIPTION_ID, lotteryAddresses[i]) {
                    emit ConsumerAdded(lotteryAddresses[i], true);
                } catch {
                    emit ConsumerAdded(lotteryAddresses[i], false);
                }
            }
        }
    }

    // 🎯 HELPER - Verificar configuración VRF
    function getVRFConfig() external pure returns (
        address vrfCoordinator,
        uint64 subscriptionId,
        bytes32 keyHash
    ) {
        return (VRF_COORDINATOR, SUBSCRIPTION_ID, KEY_HASH);
    }
}