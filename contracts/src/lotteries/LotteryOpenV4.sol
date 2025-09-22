// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Errors} from "../libs/Errors.sol";

interface ILotteryFactoryVRF {
    function requestVRFForLottery(address lotteryAddress) external returns (uint256 requestId);
}

/// @title LotteryOpenV4 - USA FACTORY COMO VRF RELAY
/// @notice Lotería que usa Factory como intermediario VRF (NO es VRFConsumer directamente)
contract LotteryOpenV4 {
    using SafeERC20 for IERC20;

    enum State { Open, Drawing, Completed, Cancelled }
    enum Currency { NATIVE, ERC20 }

    // 🎯 PACKED STORAGE - OPTIMIZADO
    struct PackedData {
        address creator;        // 20 bytes
        Currency currency;      // 1 byte
        State state;           // 1 byte
        uint32 participantCount; // 4 bytes
        uint32 vrfRequestId;   // 4 bytes (solo para tracking)
        // Total: 30 bytes, 2 bytes libres
    }
    
    PackedData public packedData;
    
    // 🎯 IMMUTABLE DATA
    address public immutable FACTORY; // Factory VRF Relay
    address public immutable TOKEN;
    uint256 public immutable TICKET_PRICE;
    
    // 🎯 DYNAMIC DATA
    string public lotteryName;
    address[] public participants;
    address public winner;
    
    // 🎯 EVENTOS
    event ParticipantJoined(address indexed user, uint256 newCount);
    event WinnerDrawn(address indexed winner, uint256 prize);
    event StateChanged(State indexed newState);
    event VRFRequested(uint256 indexed requestId);

    modifier onlyCreator() {
        require(msg.sender == packedData.creator, "Only creator");
        _;
    }
    
    modifier onlyFactory() {
        require(msg.sender == FACTORY, "Only factory");
        _;
    }

    constructor(
        address _creator,
        address _factory,
        Currency _currency,
        address _token,
        uint256 _ticketPrice,
        string memory _lotteryName
    ) {
        if (_currency == Currency.ERC20 && _token == address(0)) revert Errors.InvalidInput();
        if (_ticketPrice == 0) revert Errors.InvalidInput();
        if (_factory == address(0)) revert Errors.InvalidInput();
        
        // 🎯 INICIALIZAR PACKED DATA
        packedData = PackedData({
            creator: _creator,
            currency: _currency,
            state: State.Open,
            participantCount: 0,
            vrfRequestId: 0
        });
        
        // 🎯 IMMUTABLE ASSIGNMENTS
        FACTORY = _factory;
        TOKEN = _token;
        TICKET_PRICE = _ticketPrice;
        lotteryName = bytes(_lotteryName).length > 0 ? _lotteryName : "Unnamed Lottery";
    }

    // 🎯 PARTICIPAR EN ETH
    function enter() external payable {
        PackedData memory data = packedData;
        require(data.state == State.Open, "Not open");
        require(data.currency == Currency.NATIVE, "Wrong currency");
        require(msg.value == TICKET_PRICE, "Wrong price");

        participants.push(msg.sender);
        packedData.participantCount = data.participantCount + 1;
        
        emit ParticipantJoined(msg.sender, data.participantCount + 1);
    }

    // 🎯 PARTICIPAR CON TOKEN
    function enterWithToken() external {
        PackedData memory data = packedData;
        require(data.state == State.Open, "Not open");
        require(data.currency == Currency.ERC20, "Wrong currency");

        IERC20(TOKEN).safeTransferFrom(msg.sender, address(this), TICKET_PRICE);
        participants.push(msg.sender);
        packedData.participantCount = data.participantCount + 1;
        
        emit ParticipantJoined(msg.sender, data.participantCount + 1);
    }

    // 🚀 CERRAR LOTERÍA - USA FACTORY VRF RELAY
    function closeLottery() external onlyCreator {
        PackedData memory data = packedData;
        require(data.state == State.Open, "Not open");
        require(data.participantCount > 0, "No participants");

        // 🎯 CAMBIAR ESTADO A DRAWING
        packedData.state = State.Drawing;
        emit StateChanged(State.Drawing);

        // 🚀 PEDIR VRF AL FACTORY (NO DIRECTAMENTE A CHAINLINK)
        uint256 requestId = ILotteryFactoryVRF(FACTORY).requestVRFForLottery(address(this));
        
        // 🎯 GUARDAR REQUEST ID (SOLO PARA TRACKING)
        packedData.vrfRequestId = uint32(requestId);
        emit VRFRequested(requestId);
    }

    // 🎯 RECIBIR RANDOMNESS DEL FACTORY (SOLO FACTORY PUEDE LLAMAR)
    function receiveRandomness(uint256 randomWord) external onlyFactory {
        require(packedData.state == State.Drawing, "Not drawing");
        
        // 🎯 SELECCIONAR GANADOR
        uint256 winnerIndex = randomWord % packedData.participantCount;
        address winnerAddr = participants[winnerIndex];
        
        winner = winnerAddr;
        packedData.state = State.Completed;
        
        // 🎯 AUTO TRANSFER PREMIO
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

    // 🎯 EMERGENCY FALLBACK (SIN VRF)
    function emergencyDrawWinner() external onlyCreator {
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

    // 🎯 CANCELAR (SOLO SI ESTÁ ABIERTA)
    function cancelLottery() external onlyCreator {
        require(packedData.state == State.Open, "Cannot cancel");
        
        packedData.state = State.Cancelled;
        emit StateChanged(State.Cancelled);
        
        // 🎯 REEMBOLSAR PARTICIPANTES
        if (packedData.currency == Currency.NATIVE) {
            for (uint256 i = 0; i < participants.length; i++) {
                (bool success, ) = payable(participants[i]).call{value: TICKET_PRICE}("");
                require(success, "Refund failed");
            }
        }
        // Note: ERC20 refunds would need more complex logic
    }

    // 🎯 GETTERS
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