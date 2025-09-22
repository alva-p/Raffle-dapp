// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "./libs/Errors.sol";

interface ILotteryVRFReceiver {
    function receiveRandomness(uint256 randomWord) external;
}

/// @title VRFManager - Gestor centralizado de VRF para todas las loterías
/// @notice Un solo consumer VRF que distribuye randomness a múltiples loterías
/// @dev Elimina la necesidad de registrar cada lotería como consumer individualmente
contract VRFManager is VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface public immutable COORDINATOR;

    // VRF Configuration
    bytes32 public keyHash;
    uint64 public subscriptionId;
    uint16 public minConfirmations;
    uint32 public callbackGasLimit;

    // Request Management
    mapping(uint256 => address) public requestToLottery;
    mapping(address => bool) public authorizedCallers; // Factory contracts que pueden solicitar VRF
    
    // Events
    event VRFRequested(uint256 indexed requestId, address indexed lottery, address indexed caller);
    event VRFFulfilled(uint256 indexed requestId, address indexed lottery, uint256 randomWord);
    event CallerAuthorized(address indexed caller, bool authorized);

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

    modifier onlyAuthorized() {
        if (!authorizedCallers[msg.sender]) revert Errors.NotAuthorized();
        _;
    }

    /// @notice Autorizar/desautorizar contratos que pueden solicitar VRF
    /// @param caller Dirección del contrato (típicamente Factory)
    /// @param authorized True para autorizar, false para desautorizar
    function setAuthorizedCaller(address caller, bool authorized) external onlyOwner {
        if (caller == address(0)) revert Errors.ZeroAddress();
        authorizedCallers[caller] = authorized;
        emit CallerAuthorized(caller, authorized);
    }

    /// @notice Solicitar randomness para una lotería específica
    /// @param lottery Dirección del contrato de lotería que necesita randomness
    /// @return requestId ID del request VRF
    function requestRandomnessForLottery(address lottery) external onlyAuthorized returns (uint256) {
        if (lottery == address(0)) revert Errors.ZeroAddress();

        // Verificar que la lotería puede recibir randomness
        if (lottery.code.length == 0) revert Errors.InvalidInput();

        // Solicitar randomness a Chainlink VRF
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            minConfirmations,
            callbackGasLimit,
            1 // numWords - solo necesitamos 1 número random
        );

        // Mapear request a lotería
        requestToLottery[requestId] = lottery;

        emit VRFRequested(requestId, lottery, msg.sender);
        return requestId;
    }

    /// @notice Callback función llamada por VRF Coordinator
    /// @param requestId ID del request VRF
    /// @param randomWords Array de números random de Chainlink
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address lottery = requestToLottery[requestId];
        
        // Verificaciones de seguridad
        if (lottery == address(0)) revert Errors.InvalidRequest();
        
        uint256 randomWord = randomWords[0];
        
        // Enviar randomness a la lotería
        try ILotteryVRFReceiver(lottery).receiveRandomness(randomWord) {
            emit VRFFulfilled(requestId, lottery, randomWord);
        } catch {
            // Si falla el envío, emitir evento para debugging
            emit VRFFulfilled(requestId, lottery, randomWord);
        }
        
        // Limpiar mapping para gas efficiency
        delete requestToLottery[requestId];
    }

    /// @notice Actualizar configuración VRF (solo owner)
    function updateVRFConfig(
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint16 _minConfirmations,
        uint32 _callbackGasLimit
    ) external onlyOwner {
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        minConfirmations = _minConfirmations;
        callbackGasLimit = _callbackGasLimit;
    }

    /// @notice Función de emergencia para resolver requests atascados
    /// @param requestId ID del request atascado
    /// @param randomWord Número pseudoaleatorio para resolver
    function emergencyFulfill(uint256 requestId, uint256 randomWord) external onlyOwner {
        address lottery = requestToLottery[requestId];
        if (lottery == address(0)) revert Errors.InvalidRequest();
        
        ILotteryVRFReceiver(lottery).receiveRandomness(randomWord);
        emit VRFFulfilled(requestId, lottery, randomWord);
        
        delete requestToLottery[requestId];
    }

    /// @notice Ver información de un request activo
    /// @param requestId ID del request
    /// @return lottery Dirección de la lotería asociada
    function getRequestInfo(uint256 requestId) external view returns (address lottery) {
        return requestToLottery[requestId];
    }
}