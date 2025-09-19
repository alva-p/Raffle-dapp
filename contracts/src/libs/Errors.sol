// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Errors {
    error ZeroAddress();
    error NotCreator();
    error InvalidState();
    error InvalidInput();
    error InvalidRandomness();
    error LotteryNotOpen();
}
