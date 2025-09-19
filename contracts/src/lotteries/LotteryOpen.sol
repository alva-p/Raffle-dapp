// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LotteryBase} from "./LotteryBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Errors} from "../libs/Errors.sol";

/// @title LotteryOpen
/// @notice Lotería pública en la que cualquiera puede participar pagando ticket
contract LotteryOpen is LotteryBase {
    using SafeERC20 for IERC20;

    enum Currency { NATIVE, ERC20 }

    Currency public immutable CURRENCY;
    address  public immutable TOKEN;
    uint256  public immutable TICKET_PRICE;

    address[] internal _participants;
    address[] internal _winners;

    event Entered(address indexed user, uint256 amount);

    constructor(
        address _creator,
        address _factory,
        address _vrfCoordinator,
        uint64 _subId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        Currency _currency,
        address _token,
        uint256 _ticketPrice
    )
        LotteryBase(
            _creator,
            _factory,
            _vrfCoordinator,
            _subId,
            _keyHash,
            _callbackGasLimit,
            _requestConfirmations
        )
    {
        if (_currency == Currency.ERC20 && _token == address(0)) revert Errors.InvalidInput();
        if (_ticketPrice == 0) revert Errors.InvalidInput();
        CURRENCY = _currency;
        TOKEN = _token;
        TICKET_PRICE = _ticketPrice;
    }

    function enter() external payable {
        if (lotteryState != State.Open) revert Errors.InvalidState();
        if (CURRENCY != Currency.NATIVE) revert Errors.InvalidInput();
        if (msg.value != TICKET_PRICE) revert Errors.InvalidInput();

        _addParticipant(msg.sender);
        emit Entered(msg.sender, msg.value);
    }

    function enterWithToken() external {
        if (lotteryState != State.Open) revert Errors.InvalidState();
        if (CURRENCY != Currency.ERC20) revert Errors.InvalidInput();

        IERC20(TOKEN).safeTransferFrom(msg.sender, address(this), TICKET_PRICE);
        _addParticipant(msg.sender);
        emit Entered(msg.sender, TICKET_PRICE);
    }

    function _addParticipant(address user) internal override {
        participants.push(user);
        emit ParticipantJoined(user);
    }

    function _drawWinners(uint256 numWinners, uint256 randomWord) internal override {
        require(participants.length >= numWinners, "Not enough participants");
        delete winners;

        for (uint256 i = 0; i < numWinners; i++) {
            uint256 winnerIndex = uint256(keccak256(abi.encode(randomWord, i))) % participants.length;
            winners.push(participants[winnerIndex]);
        }
    }
}
