// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Errors} from "../libs/Errors.sol";

/// @title LotteryOpenV2 - MVP ULTRA-SIMPLE
/// @notice Lotería pública DIRECTA con VRF - SIN overhead del VRFManager
contract LotteryOpenV2 is VRFConsumerBaseV2, Ownable {
    using SafeERC20 for IERC20;

    enum State { Open, Drawing, Completed, Cancelled }
    enum Currency { NATIVE, ERC20 }

    // 🎯 VRF DIRECTO - SIN VRFMANAGER
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    uint64 public immutable SUBSCRIPTION_ID;
    bytes32 public immutable KEY_HASH;
    uint32 public constant CALLBACK_GAS_LIMIT = 100000; // Fijo y bajo
    uint16 public constant REQUEST_CONFIRMATIONS = 3;   // Fijo
    
    // 🎯 LOTTERY DATA
    address public creator;
    Currency public immutable CURRENCY;
    address public immutable TOKEN;
    uint256 public immutable TICKET_PRICE;
    string public lotteryName; // Nombre personalizable
    
    address[] public participants;
    address[] public winners;
    State public lotteryState;
    
    uint256 private vrfRequestId;

    // 🎯 EVENTOS
    event ParticipantJoined(address indexed user);
    event WinnersDrawn(address[] winners);
    event LotteryStateChanged(State newState);

    constructor(
        address _creator,
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        Currency _currency,
        address _token,
        uint256 _ticketPrice,
        string memory _lotteryName
    )
        VRFConsumerBaseV2(_vrfCoordinator)
        Ownable(_creator)
    {
        if (_currency == Currency.ERC20 && _token == address(0)) revert Errors.InvalidInput();
        if (_ticketPrice == 0) revert Errors.InvalidInput();
        
        creator = _creator;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        SUBSCRIPTION_ID = _subscriptionId;
        KEY_HASH = _keyHash;
        CURRENCY = _currency;
        TOKEN = _token;
        TICKET_PRICE = _ticketPrice;
        lotteryName = bytes(_lotteryName).length > 0 ? _lotteryName : "Unnamed Lottery";
        lotteryState = State.Open;
    }

    // 🎯 PARTICIPAR EN ETH
    function enter() external payable {
        require(lotteryState == State.Open, "Not open");
        require(CURRENCY == Currency.NATIVE, "Wrong currency");
        require(msg.value == TICKET_PRICE, "Wrong price");

        participants.push(msg.sender);
        emit ParticipantJoined(msg.sender);
    }

    // 🎯 PARTICIPAR CON TOKEN
    function enterWithToken() external {
        require(lotteryState == State.Open, "Not open");
        require(CURRENCY == Currency.ERC20, "Wrong currency");

        IERC20(TOKEN).safeTransferFrom(msg.sender, address(this), TICKET_PRICE);
        participants.push(msg.sender);
        emit ParticipantJoined(msg.sender);
    }

    // 🎯 CERRAR Y SOLICITAR VRF - SUPER SIMPLE
    function closeLottery() external {
        require(msg.sender == creator, "Only creator");
        require(lotteryState == State.Open, "Not open");
        require(participants.length > 0, "No participants");

        lotteryState = State.Drawing;
        emit LotteryStateChanged(State.Drawing);

        // 🚀 VRF DIRECTO - SIN VRFMANAGER
        vrfRequestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            SUBSCRIPTION_ID,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            1 // Solo 1 número random
        );
    }

    // 🎯 RECIBIR VRF Y ELEGIR GANADOR - AUTO TRANSFER
    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        if (lotteryState != State.Drawing) return;
        
        uint256 randomWord = randomWords[0];
        uint256 winnerIndex = randomWord % participants.length;
        address winner = participants[winnerIndex];
        
        winners.push(winner);
        lotteryState = State.Completed;
        
        emit WinnersDrawn(winners);
        
        // 🎯 TRANSFERENCIA AUTOMÁTICA
        _transferPrize(winner);
    }

    // 🎯 TRANSFERIR PREMIO AUTOMÁTICAMENTE
    function _transferPrize(address winner) internal {
        if (CURRENCY == Currency.NATIVE) {
            uint256 prize = address(this).balance;
            if (prize > 0) {
                (bool success, ) = payable(winner).call{value: prize}("");
                require(success, "Prize transfer failed");
            }
        } else {
            uint256 prize = IERC20(TOKEN).balanceOf(address(this));
            if (prize > 0) {
                IERC20(TOKEN).safeTransfer(winner, prize);
            }
        }
    }

    // 🎯 EMERGENCY - SOLO SI VRF FALLA
    function emergencyDrawWinner() external {
        require(msg.sender == creator, "Only creator");
        require(lotteryState == State.Drawing, "Not drawing");
        
        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            participants.length
        )));
        
        uint256 winnerIndex = pseudoRandom % participants.length;
        address winner = participants[winnerIndex];
        
        winners.push(winner);
        lotteryState = State.Completed;
        
        emit WinnersDrawn(winners);
        _transferPrize(winner);
    }

    // 🎯 CANCELAR Y REEMBOLSAR
    function cancelLottery() external {
        require(msg.sender == creator, "Only creator");
        require(lotteryState == State.Open, "Cannot cancel");
        
        lotteryState = State.Cancelled;
        emit LotteryStateChanged(State.Cancelled);
        
        if (CURRENCY == Currency.NATIVE) {
            for (uint256 i = 0; i < participants.length; i++) {
                (bool success, ) = payable(participants[i]).call{value: TICKET_PRICE}("");
                require(success, "Refund failed");
            }
        }
    }

    // 🎯 GETTERS
    function getParticipants() external view returns (address[] memory) {
        return participants;
    }
    
    function getWinners() external view returns (address[] memory) {
        return winners;
    }
    
    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }
    
    function getPrizePool() external view returns (uint256) {
        if (CURRENCY == Currency.NATIVE) {
            return address(this).balance;
        } else {
            return IERC20(TOKEN).balanceOf(address(this));
        }
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
        bool isOpen,
        bool isFull,
        bool isExpired
    ) {
        return (
            lotteryName,
            creator,
            lotteryState,
            CURRENCY,
            TOKEN,
            TICKET_PRICE,
            participants.length,
            this.getPrizePool(),
            lotteryState == State.Open,
            false, // unlimited participants
            false  // no expiration implemented yet
        );
    }
}