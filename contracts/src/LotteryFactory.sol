// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import {LotteryOpen} from "../src/lotteries/LotteryOpen.sol";

/// @title LotteryFactory
/// @notice Despliega loterías y gestiona las llamadas de VRF
contract LotteryFactory is VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    bytes32 public keyHash;
    uint64  public subscriptionId;
    uint16  public minConfirmations;
    uint32  public callbackGasLimit;

    mapping(uint256 => address) public requestToLottery;
    address[] public allLotteries;
    mapping(address => bool) public isLottery;

    event LotteryCreated(address indexed creator, address indexed lottery);
    event RandomRequested(uint256 indexed requestId, address indexed lottery);

    constructor(
        address _owner,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint16 _minConfirmations,
        uint32 _callbackGasLimit
    )
        VRFConsumerBaseV2(_vrfCoordinator)
        Ownable(_owner)
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        minConfirmations = _minConfirmations;
        callbackGasLimit = _callbackGasLimit;
    }

    function createLotteryOpen(
        LotteryOpen.Currency currency,
        address token,
        uint256 ticketPrice
    ) external returns (address lot) {
        lot = address(
            new LotteryOpen(
                msg.sender,
                address(this),
                address(COORDINATOR),
                subscriptionId,
                keyHash,
                callbackGasLimit,
                minConfirmations,
                currency,
                token,
                ticketPrice
            )
        );
        isLottery[lot] = true;
        allLotteries.push(lot);
        emit LotteryCreated(msg.sender, lot);
    }

    function getAllLotteries() external view returns (address[] memory) {
        return allLotteries;
    }

    function requestRandomness(address lottery, uint32 numWords) external returns (uint256 requestId) {
        require(isLottery[lottery], "NotLottery");
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            minConfirmations,
            callbackGasLimit,
            numWords
        );
        requestToLottery[requestId] = lottery;
        emit RandomRequested(requestId, lottery);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address lot = requestToLottery[requestId];
        require(isLottery[lot], "Unknown req");
        (bool ok,) = lot.call(abi.encodeWithSignature("fulfillRandomWords(uint256,uint256[])", requestId, randomWords));
        require(ok, "Callback failed");
    }
}
