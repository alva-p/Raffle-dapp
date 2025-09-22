// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Errors} from "../libs/Errors.sol";

/// @title LotteryOpenV3 - ULTRA OPTIMIZADO CON PACKED STORAGE
/// @notice Lotería pública optimizada para mínimo gas cost
contract LotteryOpenV3 is VRFConsumerBaseV2 {
    using SafeERC20 for IERC20;

    enum State { Open, Drawing, Completed, Cancelled }
    enum Currency { NATIVE, ERC20 }

    // 🎯 VRF CONFIG - RECIBIDO COMO PARÁMETROS INDIVIDUALES

    // 🎯 PACKED STORAGE - SLOT 1 (32 bytes)
    struct PackedData {
        address creator;        // 20 bytes
        Currency currency;      // 1 byte
        State state;           // 1 byte
        uint32 participantCount; // 4 bytes
        uint32 vrfRequestId;   // 4 bytes (truncado para ahorro)
        // Total: 30 bytes, 2 bytes libres
    }
    
    PackedData public packedData;
    
    // 🎯 IMMUTABLE DATA (NO STORAGE COST)
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    uint64 public immutable SUBSCRIPTION_ID;
    uint32 public immutable CALLBACK_GAS_LIMIT;
    bytes32 public immutable KEY_HASH;
    address public immutable TOKEN;
    uint256 public immutable TICKET_PRICE;
    
    // 🎯 DYNAMIC DATA
    string public lotteryName;
    address[] public participants;
    address public winner; // Solo 1 ganador para simplificar
    
    // 🎯 EVENTOS OPTIMIZADOS (INDEXED PARAMETERS MÍNIMOS)
    event ParticipantJoined(address indexed user, uint256 newCount);
    event WinnerDrawn(address indexed winner, uint256 prize);
    event StateChanged(State indexed newState);

    constructor(
        address _creator,
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        Currency _currency,
        address _token,
        uint256 _ticketPrice,
        string memory _lotteryName
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        if (_currency == Currency.ERC20 && _token == address(0)) revert Errors.InvalidInput();
        if (_ticketPrice == 0) revert Errors.InvalidInput();
        
        // 🎯 INICIALIZAR PACKED DATA
        packedData = PackedData({
            creator: _creator,
            currency: _currency,
            state: State.Open,
            participantCount: 0,
            vrfRequestId: 0
        });
        
        // 🎯 IMMUTABLE ASSIGNMENTS
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        SUBSCRIPTION_ID = _subscriptionId;
        CALLBACK_GAS_LIMIT = _callbackGasLimit;
        KEY_HASH = _keyHash;
        TOKEN = _token;
        TICKET_PRICE = _ticketPrice;
        lotteryName = bytes(_lotteryName).length > 0 ? _lotteryName : "Unnamed Lottery";
    }

    // 🎯 PARTICIPAR EN ETH - OPTIMIZADO
    function enter() external payable {
        PackedData memory data = packedData; // 1 SLOAD
        require(data.state == State.Open, "Not open");
        require(data.currency == Currency.NATIVE, "Wrong currency");
        require(msg.value == TICKET_PRICE, "Wrong price");

        participants.push(msg.sender);
        
        // 🎯 ACTUALIZAR PACKED DATA - 1 SSTORE
        packedData.participantCount = data.participantCount + 1;
        
        emit ParticipantJoined(msg.sender, data.participantCount + 1);
    }

    // 🎯 PARTICIPAR CON TOKEN - OPTIMIZADO
    function enterWithToken() external {
        PackedData memory data = packedData; // 1 SLOAD
        require(data.state == State.Open, "Not open");
        require(data.currency == Currency.ERC20, "Wrong currency");

        IERC20(TOKEN).safeTransferFrom(msg.sender, address(this), TICKET_PRICE);
        participants.push(msg.sender);
        
        // 🎯 ACTUALIZAR PACKED DATA - 1 SSTORE
        packedData.participantCount = data.participantCount + 1;
        
        emit ParticipantJoined(msg.sender, data.participantCount + 1);
    }

    // 🎯 CERRAR LOTERÍA - SOLO CREATOR
    function closeLottery() external {
        PackedData memory data = packedData; // 1 SLOAD
        require(msg.sender == data.creator, "Only creator");
        require(data.state == State.Open, "Not open");
        require(data.participantCount > 0, "No participants");

        // 🎯 ACTUALIZAR STATE - 1 SSTORE
        packedData.state = State.Drawing;
        emit StateChanged(State.Drawing);

        // 🚀 VRF REQUEST
        uint256 requestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            SUBSCRIPTION_ID,
            3, // REQUEST_CONFIRMATIONS
            CALLBACK_GAS_LIMIT,
            1
        );
        
        // 🎯 GUARDAR REQUEST ID TRUNCADO
        packedData.vrfRequestId = uint32(requestId);
    }

    // 🎯 VRF CALLBACK - AUTO TRANSFER
    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        if (packedData.state != State.Drawing) return;
        
        uint256 randomWord = randomWords[0];
        uint256 winnerIndex = randomWord % packedData.participantCount;
        address winnerAddr = participants[winnerIndex];
        
        winner = winnerAddr;
        packedData.state = State.Completed;
        
        // 🎯 AUTO TRANSFER
        uint256 prize = _transferPrize(winnerAddr);
        emit WinnerDrawn(winnerAddr, prize);
    }

    // 🎯 TRANSFER OPTIMIZADO
    function _transferPrize(address winnerAddr) internal returns (uint256 prize) {
        if (packedData.currency == Currency.NATIVE) {
            prize = address(this).balance;
            if (prize > 0) {
                (bool success, ) = payable(winnerAddr).call{value: prize}("");
                require(success, "Prize transfer failed");
            }
        } else {
            prize = IERC20(TOKEN).balanceOf(address(this));
            if (prize > 0) {
                IERC20(TOKEN).safeTransfer(winnerAddr, prize);
            }
        }
    }

    // 🎯 EMERGENCY FALLBACK
    function emergencyDrawWinner() external {
        require(msg.sender == packedData.creator, "Only creator");
        require(packedData.state == State.Drawing, "Not drawing");
        
        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            packedData.participantCount
        )));
        
        uint256 winnerIndex = pseudoRandom % packedData.participantCount;
        address winnerAddr = participants[winnerIndex];
        
        winner = winnerAddr;
        packedData.state = State.Completed;
        
        uint256 prize = _transferPrize(winnerAddr);
        emit WinnerDrawn(winnerAddr, prize);
    }

    // 🎯 GETTERS OPTIMIZADOS
    function getPrizePool() external view returns (uint256) {
        return packedData.currency == Currency.NATIVE ? 
            address(this).balance : 
            IERC20(TOKEN).balanceOf(address(this));
    }
    
    function getParticipants() external view returns (address[] memory) {
        return participants;
    }
    
    function getLotteryInfo() external view returns (
        string memory name,
        address creatorAddr,
        State state,
        Currency currency,
        address token,
        uint256 ticketPrice,
        uint256 participantCount,
        uint256 prizePool,
        address winnerAddr
    ) {
        PackedData memory data = packedData;
        return (
            lotteryName,
            data.creator,
            data.state,
            data.currency,
            TOKEN,
            TICKET_PRICE,
            data.participantCount,
            this.getPrizePool(),
            winner
        );
    }
}