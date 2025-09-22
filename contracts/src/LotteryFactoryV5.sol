// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LotteryOpenV2} from "./lotteries/LotteryOpenV2.sol";
import {Errors} from "./libs/Errors.sol";

/// @title LotteryFactoryV5 - MVP ULTRA-SIMPLE
/// @notice Factory para crear loterias públicas DIRECTAS con VRF - SIN VRFManager
contract LotteryFactoryV5 is Ownable {
    
    // 🎯 VRF CONFIG DIRECTO
    address public constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // Sepolia
    uint64 public constant SUBSCRIPTION_ID = 12478;
    bytes32 public constant KEY_HASH = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    address[] public allLotteries;
    mapping(address => bool) public isLotteryFromFactory;

    event LotteryCreated(address indexed lottery, address indexed creator, uint256 ticketPrice);

    constructor() Ownable(msg.sender) {}

    // 🎯 CREAR LOTERÍA PÚBLICA DIRECTA - CON NOMBRE PERSONALIZABLE
    function createLotteryOpen(
        uint8 currency,
        address token,
        uint256 ticketPrice,
        string calldata lotteryName
    ) external returns (address) {
        if (ticketPrice == 0) revert Errors.InvalidInput();
        if (currency == 1 && token == address(0)) revert Errors.InvalidInput(); // ERC20 needs token
        
        LotteryOpenV2 newLottery = new LotteryOpenV2(
            msg.sender,                                    // creator
            VRF_COORDINATOR,                               // vrfCoordinator
            SUBSCRIPTION_ID,                               // subscriptionId
            KEY_HASH,                                      // keyHash
            LotteryOpenV2.Currency(currency),              // currency (0=ETH, 1=TOKEN)
            token,                                         // token (address(0) for ETH)
            ticketPrice,                                   // ticketPrice
            lotteryName                                    // nombre personalizable
        );

        address lotteryAddress = address(newLottery);
        allLotteries.push(lotteryAddress);
        isLotteryFromFactory[lotteryAddress] = true;

        emit LotteryCreated(lotteryAddress, msg.sender, ticketPrice);
        return lotteryAddress;
    }

    // 🎯 GETTERS
    function getAllLotteries() external view returns (address[] memory) {
        return allLotteries;
    }

    function getLotteryCount() external view returns (uint256) {
        return allLotteries.length;
    }
}