// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import {ILottery} from "../interfaces/ILottery.sol";
import {Errors} from "../libs/Errors.sol";

/// @title LotteryBase
/// @notice Lógica común para cualquier tipo de lotería
abstract contract LotteryBase is VRFConsumerBaseV2, Ownable, ILottery {
    address public creator;
    address public factory;

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
    }

    modifier onlyCreator() {
        if (msg.sender != creator) revert Errors.NotCreator();
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
}
