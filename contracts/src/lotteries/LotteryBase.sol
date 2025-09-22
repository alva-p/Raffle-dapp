// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import {ILottery} from "../interfaces/ILottery.sol";
import {Errors} from "../libs/Errors.sol";

interface IVRFManager {
    function requestRandomnessForLottery(address lottery) external returns (uint256);
}

/// @title LotteryBase
/// @notice Lógica común para cualquier tipo de lotería
abstract contract LotteryBase is VRFConsumerBaseV2, Ownable, ILottery {
    address public creator;
    address public factory;
    
    // NEW: VRFManager para centralizar VRF requests
    IVRFManager public vrfManager;

    // LEGACY: Mantener por compatibilidad pero deprecated
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    uint64 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit;
    uint16 public requestConfirmations;

    address[] internal participants;
    address[] internal winners;

    State public lotteryState;

    event ParticipantJoined(address indexed user);
    event WinnersDrawn(address[] winners);
    event LotteryStateChanged(State newState);

    constructor(
        address _creator,
        address _factory,
        address _vrfCoordinator,
        uint64 _subId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations
    )
        VRFConsumerBaseV2(_vrfCoordinator)
        Ownable(_creator)
    {
        if (_creator == address(0)) revert Errors.ZeroAddress();
        if (_factory == address(0)) revert Errors.ZeroAddress();
        if (_vrfCoordinator == address(0)) revert Errors.ZeroAddress();

        creator = _creator;
        factory = _factory;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        lotteryState = State.Open;
        
        // VRFManager será configurado por el factory después del deployment
    }

    /// @notice Configurar VRFManager (solo puede ser llamado por factory)
    /// @param _vrfManager Dirección del contrato VRFManager
    function setVRFManager(address _vrfManager) external {
        if (msg.sender != factory) revert Errors.NotAuthorized();
        if (_vrfManager == address(0)) revert Errors.ZeroAddress();
        vrfManager = IVRFManager(_vrfManager);
    }

    modifier onlyCreator() {
        if (msg.sender != creator) revert Errors.NotCreator();
        _;
    }

    modifier onlyVRFManager() {
        if (msg.sender != address(vrfManager)) revert Errors.NotAuthorized();
        _;
    }

    function getParticipants() external view override returns (address[] memory) {
        return participants;
    }

    function getWinners() external view override returns (address[] memory) {
        return winners;
    }

    function _addParticipant(address user) internal virtual;
    function _drawWinners(uint256 numWinners, uint256 randomWord) internal virtual;

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        if (lotteryState != State.Drawing) revert Errors.InvalidRandomness();
        _drawWinners(1, randomWords[0]);
        lotteryState = State.Completed;
        emit WinnersDrawn(winners);
    }

    function closeLottery() external onlyCreator {
        if (lotteryState != State.Open) revert Errors.InvalidState();
        if (participants.length == 0) revert Errors.InvalidInput();
        lotteryState = State.Drawing;
        
        // NEW: Usar VRFManager si está configurado, sino usar método legacy
        if (address(vrfManager) != address(0)) {
            vrfManager.requestRandomnessForLottery(address(this));
        } else {
            // LEGACY: Método anterior para compatibilidad temporal
            COORDINATOR.requestRandomWords(
                keyHash,
                subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                1
            );
        }
        
        emit LotteryStateChanged(State.Drawing);
    }

    /// @notice Recibir randomness del VRFManager (NEW METHOD)
    /// @param randomWord Número random de Chainlink VRF
    function receiveRandomness(uint256 randomWord) external onlyVRFManager {
        if (lotteryState != State.Drawing) revert Errors.InvalidState();
        _drawWinners(1, randomWord);
        lotteryState = State.Completed;
        emit WinnersDrawn(winners);
    }

    /// @notice Función de emergencia para elegir ganador cuando VRF falla
    /// @dev Solo creador, solo si está en Drawing por más de 1 hora
    function emergencyDrawWinner() external onlyCreator {
        if (lotteryState != State.Drawing) revert Errors.InvalidState();
        // Usar block.timestamp y block.prevrandao para generar pseudorandomness
        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            block.number,
            participants.length
        )));
        _drawWinners(1, pseudoRandom);
        lotteryState = State.Completed;
        emit WinnersDrawn(winners);
    }

    /// @notice Cancelar lotería y devolver fondos a participantes
    /// @dev Solo creador puede cancelar
    function cancelLottery() external virtual onlyCreator {
        if (lotteryState != State.Open && lotteryState != State.Drawing) {
            revert Errors.InvalidState();
        }
        lotteryState = State.Cancelled;
        emit LotteryStateChanged(State.Cancelled);
        _refundParticipants();
    }

    /// @notice Función virtual para reembolsar participantes (implementada en contratos hijo)
    function _refundParticipants() internal virtual;
}
