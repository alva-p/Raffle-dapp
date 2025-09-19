// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {LotteryOpen} from "../lotteries/LotteryOpen.sol";
import {ILottery} from "../interfaces/ILottery.sol";


// Harness para exponer helpers de test sin tocar prod
contract LotteryOpenHarness is LotteryOpen {
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
        LotteryOpen(
            _creator,
            _factory,
            _vrfCoordinator,
            _subId,
            _keyHash,
            _callbackGasLimit,
            _requestConfirmations,
            _currency,
            _token,
            _ticketPrice
        )
    {}

    function addParticipantForTest(address user) external {
        _addParticipant(user);
    }

    function setStateForTest(State s) external {
        lotteryState = s;
    }

    function drawForTest(uint256 n, uint256 seed) external {
        _drawWinners(n, seed);
        lotteryState = State.Completed;
    }
}

contract LotteryOpenTest is Test {
    LotteryOpenHarness lot;

    function setUp() public {
        // Valores dummy para VRF (no los usamos en este test)
        address creator = address(this);
        address factory = address(this);
        address vrfCoord = address(0xBEEF);
        uint64 subId = 1;
        bytes32 keyHash = bytes32(uint256(123));
        uint32 cbGas = 500_000;
        uint16 minConf = 3;

        lot = new LotteryOpenHarness(
            creator,
            factory,
            vrfCoord,
            subId,
            keyHash,
            cbGas,
            minConf,
            LotteryOpen.Currency.NATIVE,
            address(0),
            1 wei // no lo usamos porque no llamamos enter()
        );

        // Agregamos 5 participantes
        for (uint256 i = 1; i <= 5; i++) {
            lot.addParticipantForTest(address(uint160(i)));
        }
    }

    function test_Draw3UniqueWinners() public {
        // Forzar estado Drawing
        lot.setStateForTest(ILottery.State.Drawing);

        // Hacer draw determinístico con seed=42
        lot.drawForTest(3, 42);

        address[] memory w = lot.getWinners();
        assertEq(w.length, 3, "Debe haber 3 ganadores");

        // Unicidad
        assertTrue(w[0] != w[1] && w[0] != w[2] && w[1] != w[2]);
    }
}
