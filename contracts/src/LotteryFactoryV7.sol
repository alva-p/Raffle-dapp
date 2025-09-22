// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {LotteryOpenV4} from "./lotteries/LotteryOpenV4.sol";
import {Errors} from "./libs/Errors.sol";

/// @title LotteryFactoryV7 - VRF RELAY PATTERN
/// @notice Factory que actúa como único consumer VRF y reenvía respuestas a loterías
contract LotteryFactoryV7 is Ownable, VRFConsumerBaseV2 {
    
    // 🎯 VRF CONFIG - FACTORY ES EL ÚNICO CONSUMER
    address public constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 public constant SUBSCRIPTION_ID = 12478;
    uint32 public constant CALLBACK_GAS_LIMIT = 100000; // 🚀 AUMENTADO PARA VRF RELAY
    bytes32 public constant KEY_HASH = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    
    // 🎯 VRF COORDINATOR INTERFACE
    VRFCoordinatorV2Interface private immutable COORDINATOR;
    
    // 🎯 STORAGE
    address[] public allLotteries;
    mapping(address => bool) public isLotteryFromFactory;
    uint256 private _lotteryCounter;
    
    // 🎯 VRF RELAY MAPPING
    mapping(uint256 => address) public vrfRequestToLottery; // requestId => lotteryAddress
    mapping(address => uint256) public lotteryToVrfRequest; // lotteryAddress => requestId
    
    // 🎯 EVENTS
    event LotteryCreated(address indexed lottery, address indexed creator, uint256 ticketPrice, string name);
    event VRFRequested(address indexed lottery, uint256 indexed requestId);
    event VRFFullfilled(address indexed lottery, uint256 indexed requestId, uint256 randomWord);

    constructor() Ownable(msg.sender) VRFConsumerBaseV2(VRF_COORDINATOR) {
        COORDINATOR = VRFCoordinatorV2Interface(VRF_COORDINATOR);
    }

    // 🎯 CREAR LOTERÍA (SIN VRF DIRECTO)
    function createLotteryOpen(
        uint8 currency,
        address token,
        uint256 ticketPrice,
        string calldata lotteryName
    ) external returns (address) {
        if (ticketPrice == 0) revert Errors.InvalidInput();
        if (currency == 1 && token == address(0)) revert Errors.InvalidInput();
        
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, _lotteryCounter++));
        
        LotteryOpenV4 newLottery = new LotteryOpenV4{salt: salt}(
            msg.sender,                                    // creator
            address(this),                                 // factory (VRF relay)
            LotteryOpenV4.Currency(currency),              // currency
            token,                                         // token
            ticketPrice,                                   // ticketPrice
            lotteryName                                    // nombre
        );

        address lotteryAddress = address(newLottery);
        allLotteries.push(lotteryAddress);
        isLotteryFromFactory[lotteryAddress] = true;

        emit LotteryCreated(lotteryAddress, msg.sender, ticketPrice, lotteryName);
        return lotteryAddress;
    }

    // 🚀 VRF RELAY - FUNCIÓN PRINCIPAL
    function requestVRFForLottery(address lotteryAddress) external returns (uint256 requestId) {
        // Solo loterías del factory pueden usar VRF
        require(isLotteryFromFactory[lotteryAddress], "Not from this factory");
        
        // Solo la lotería misma puede pedir VRF
        require(msg.sender == lotteryAddress, "Only lottery can request");
        
        // Verificar que no haya request pendiente
        require(lotteryToVrfRequest[lotteryAddress] == 0, "VRF already requested");

        // 🎯 HACER VRF REQUEST A CHAINLINK
        requestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            SUBSCRIPTION_ID,
            3, // REQUEST_CONFIRMATIONS
            CALLBACK_GAS_LIMIT,
            1  // numWords
        );
        
        // 🎯 MAPEAR REQUEST → LOTTERY
        vrfRequestToLottery[requestId] = lotteryAddress;
        lotteryToVrfRequest[lotteryAddress] = requestId;
        
        emit VRFRequested(lotteryAddress, requestId);
        return requestId;
    }

    // 🎯 CHAINLINK VRF CALLBACK - REENVÍA A LOTERÍA
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address lotteryAddress = vrfRequestToLottery[requestId];
        require(lotteryAddress != address(0), "Invalid request ID");
        
        uint256 randomWord = randomWords[0];
        
        // 🎯 REENVIAR A LOTERÍA ESPECÍFICA
        LotteryOpenV4(lotteryAddress).receiveRandomness(randomWord);
        
        // 🎯 LIMPIAR MAPPINGS
        delete vrfRequestToLottery[requestId];
        delete lotteryToVrfRequest[lotteryAddress];
        
        emit VRFFullfilled(lotteryAddress, requestId, randomWord);
    }

    // 🎯 EMERGENCY - LIMPIAR REQUEST STUCK
    function clearStuckRequest(address lotteryAddress) external onlyOwner {
        uint256 requestId = lotteryToVrfRequest[lotteryAddress];
        if (requestId != 0) {
            delete vrfRequestToLottery[requestId];
            delete lotteryToVrfRequest[lotteryAddress];
        }
    }

    // 🎯 GETTERS
    function getAllLotteries() external view returns (address[] memory) {
        return allLotteries;
    }

    function getLotteryCount() external view returns (uint256) {
        return allLotteries.length;
    }
    
    function getNextLotteryCounter() external view returns (uint256) {
        return _lotteryCounter;
    }

    function getVRFConfig() external pure returns (
        address vrfCoordinator,
        uint64 subscriptionId,
        bytes32 keyHash
    ) {
        return (VRF_COORDINATOR, SUBSCRIPTION_ID, KEY_HASH);
    }
    
    // 🎯 VERIFICAR SI LOTERÍA TIENE VRF PENDIENTE
    function hasVRFPending(address lotteryAddress) external view returns (bool) {
        return lotteryToVrfRequest[lotteryAddress] != 0;
    }
}