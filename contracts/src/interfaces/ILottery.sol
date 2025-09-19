// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ILottery {
    enum State { Pending, Open, Locked, Drawing, Completed, Cancelled }

    function getParticipants() external view returns (address[] memory);
    function getWinners() external view returns (address[] memory);
}
