// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ILotteryRandomReceiver
 * @notice Lottery instances implement this to receive randomness from the Factory (VRF consumer).
 */
interface ILotteryRandomReceiver {
    /**
     * @notice Called by the Factory when VRF fulfills randomness.
     * @param requestId Chainlink VRF request id.
     * @param randomWords Random words provided by VRF.
     */
    function onRandomSeed(uint256 requestId, uint256[] calldata randomWords) external;
}
