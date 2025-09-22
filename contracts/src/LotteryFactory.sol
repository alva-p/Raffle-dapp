// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import {LotteryOpen} from "../src/lotteries/LotteryOpen.sol";
import {LotteryPrivate} from "../src/lotteries/LotteryPrivate.sol";
import {VRFManager} from "./VRFManager.sol";

interface ILotteryBase {
    function setVRFManager(address _vrfManager) external;
}

/// @title LotteryFactory
/// @notice Despliega loterías y gestiona las llamadas de VRF
contract LotteryFactory is VRFConsumerBaseV2, Ownable {
    // NEW: VRFManager centralizado
    VRFManager public vrfManager;
    
    // LEGACY: Mantener para compatibilidad
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    bytes32 public keyHash;
    uint64  public subscriptionId;
    uint16  public minConfirmations;
    uint32  public callbackGasLimit;

    mapping(uint256 => address) public requestToLottery;
    address[] public allLotteries;
    mapping(address => bool) public isLottery;

    event LotteryCreated(address indexed creator, address indexed lottery);
    event RandomRequested(uint256 indexed requestId, address indexed lottery);

    constructor(
        address _owner,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint16 _minConfirmations,
        uint32 _callbackGasLimit
    )
        VRFConsumerBaseV2(_vrfCoordinator)
        Ownable(_owner)
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        minConfirmations = _minConfirmations;
        callbackGasLimit = _callbackGasLimit;
    }

    function createLotteryOpen(
        LotteryOpen.Currency currency,
        address token,
        uint256 ticketPrice
    ) external returns (address lot) {
        lot = address(
            new LotteryOpen(
                msg.sender,
                address(this),
                address(COORDINATOR),
                subscriptionId,
                keyHash,
                callbackGasLimit,
                minConfirmations,
                currency,
                token,
                ticketPrice
            )
        );
        
        // NEW: Configurar VRFManager si está disponible
        if (address(vrfManager) != address(0)) {
            ILotteryBase(lot).setVRFManager(address(vrfManager));
        }
        
        isLottery[lot] = true;
        allLotteries.push(lot);
        emit LotteryCreated(msg.sender, lot);
    }

    function createLotteryPrivate(
        LotteryPrivate.Currency currency,
        address token,
        uint256 ticketPrice
    ) external returns (address lot) {
        lot = address(
            new LotteryPrivate(
                currency,
                token,
                ticketPrice,
                msg.sender,
                address(this), // Factory address
                address(COORDINATOR),
                subscriptionId
            )
        );
        
        // NEW: Configurar VRFManager si está disponible
        if (address(vrfManager) != address(0)) {
            ILotteryBase(lot).setVRFManager(address(vrfManager));
        }
        
        isLottery[lot] = true;
        allLotteries.push(lot);
        emit LotteryCreated(msg.sender, lot);
    }

    function getAllLotteries() external view returns (address[] memory) {
        return allLotteries;
    }

    function requestRandomness(address lottery, uint32 numWords) external returns (uint256 requestId) {
        require(isLottery[lottery], "NotLottery");
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            minConfirmations,
            callbackGasLimit,
            numWords
        );
        requestToLottery[requestId] = lottery;
        emit RandomRequested(requestId, lottery);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address lot = requestToLottery[requestId];
        require(isLottery[lot], "Unknown req");
        (bool ok,) = lot.call(abi.encodeWithSignature("fulfillRandomWords(uint256,uint256[])", requestId, randomWords));
        require(ok, "Callback failed");
    }

    /// @notice Configurar VRFManager (solo owner)
    /// @param _vrfManager Dirección del contrato VRFManager
    function setVRFManager(address _vrfManager) external onlyOwner {
        vrfManager = VRFManager(_vrfManager);
        
        // Autorizar este factory en el VRFManager
        if (address(vrfManager) != address(0)) {
            // El VRFManager debe tener una función para autorizar este factory
            // Esto se hará manualmente después del deploy
        }
    }

    /// @notice Configurar VRFManager en loterías existentes (solo owner)
    /// @param _vrfManager Dirección del VRFManager
    /// @param startIndex Índice inicial para actualizar (para evitar out of gas)
    /// @param endIndex Índice final para actualizar
    function updateExistingLotteries(address _vrfManager, uint256 startIndex, uint256 endIndex) external onlyOwner {
        require(endIndex <= allLotteries.length, "Invalid range");
        require(startIndex <= endIndex, "Invalid range");
        
        for (uint256 i = startIndex; i < endIndex; i++) {
            try ILotteryBase(allLotteries[i]).setVRFManager(_vrfManager) {
                // Success
            } catch {
                // Skip failed updates
            }
        }
    }

    /// @notice Get VRFManager address
    function getVRFManager() external view returns (address) {
        return address(vrfManager);
    }
}
