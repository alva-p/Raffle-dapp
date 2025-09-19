// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Errors} from "../libs/Errors.sol";
import {LotteryBase} from "./LotteryBase.sol";

/// @title LotteryClosed
/// @notice Lotería con lista cerrada de participantes
/// @dev El creador pasa la lista inicial, nadie más puede unirse públicamente
contract LotteryClosed is LotteryBase {
    string public ipfsCid; // optional pointer to off-chain list

    constructor(
        address _creator,
        address _factory,
        address _vrfCoordinator,
        uint64 _subId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        address[] memory initialParticipants,
        string memory _ipfsCid
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
        if (initialParticipants.length == 0) revert Errors.InvalidInput();
        for (uint256 i = 0; i < initialParticipants.length; i++) {
            _addParticipant(initialParticipants[i]);
        }
        ipfsCid = _ipfsCid;
        lotteryState = State.Pending;
    }

    /// @notice Batch add participants before locking (solo creador)
    function addParticipantsBatch(address[] calldata addrs) external onlyCreator {
        if (lotteryState != State.Pending) revert Errors.InvalidState();
        for (uint256 i = 0; i < addrs.length; i++) {
            _addParticipant(addrs[i]);
        }
    }

    /// @dev implementa la función abstracta de LotteryBase
    function _addParticipant(address user) internal override {
        participants.push(user);
        emit ParticipantJoined(user);
    }

    /// @dev implementación simple de _drawWinners
    function _drawWinners(uint256 numWinners, uint256 randomWord) internal override {
        require(participants.length >= numWinners, "Not enough participants");
        delete winners;

        for (uint256 i = 0; i < numWinners; i++) {
            uint256 winnerIndex = uint256(keccak256(abi.encode(randomWord, i))) % participants.length;
            winners.push(participants[winnerIndex]);
        }
    }
}
