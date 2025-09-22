// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

/// @title VRFTest - Contrato simple para probar VRF
/// @notice Contrato minimalista para verificar si VRF funciona correctamente
contract VRFTest is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    // VRF Configuration
    uint64 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    // VRF Results
    uint256[] public randomWords;
    uint256 public requestId;
    bool public vrfFulfilled = false;
    uint256 public requestTimestamp;
    
    event RandomnessRequested(uint256 indexed requestId, uint256 timestamp);
    event RandomnessFulfilled(uint256 indexed requestId, uint256[] randomWords, uint256 timestamp);

    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    /// @notice Request randomness from VRF
    function requestRandomness() external returns (uint256) {
        // Reset previous results
        delete randomWords;
        vrfFulfilled = false;
        requestTimestamp = block.timestamp;
        
        // Request randomness
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        
        emit RandomnessRequested(requestId, requestTimestamp);
        return requestId;
    }

    /// @notice Callback function used by VRF Coordinator
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        randomWords = _randomWords;
        vrfFulfilled = true;
        emit RandomnessFulfilled(_requestId, _randomWords, block.timestamp);
    }

    /// @notice Get the random number (if fulfilled)
    function getRandomNumber() external view returns (uint256) {
        require(vrfFulfilled, "VRF not fulfilled yet");
        return randomWords[0];
    }

    /// @notice Get test results
    function getTestResults() external view returns (
        uint256 _requestId,
        bool _fulfilled,
        uint256 _randomWord,
        uint256 _requestTime,
        uint256 _timePassed
    ) {
        return (
            requestId,
            vrfFulfilled,
            vrfFulfilled ? randomWords[0] : 0,
            requestTimestamp,
            block.timestamp - requestTimestamp
        );
    }

    /// @notice Check if VRF is working (returns time since request)
    function checkVRFStatus() external view returns (string memory status, uint256 timePassed) {
        if (requestId == 0) {
            return ("No request made", 0);
        }
        
        timePassed = block.timestamp - requestTimestamp;
        
        if (vrfFulfilled) {
            return ("VRF Success!", timePassed);
        } else if (timePassed > 300) { // 5 minutes
            return ("VRF Timeout - Check consumers/subscription", timePassed);
        } else {
            return ("VRF Pending...", timePassed);
        }
    }
}