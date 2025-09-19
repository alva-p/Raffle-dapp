// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../lotteries/LotteryClosed.sol";
import "../libs/Errors.sol";

contract LotteryClosedTest is Test {
    LotteryClosed public lottery;
    address public creator = address(0xA11CE);
    address public user1 = address(0xBEEF);
    address public user2 = address(0xCAFE);
    address public user3 = address(0xF00D);

    function setUp() public {
        // lista inicial de participantes
        address ;
        initial[0] = user1;
        initial[1] = user2;

        lottery = new LotteryClosed(
            creator,
            1, // numWinners
            initial,
            10, // maxParticipants
            "ipfs://cid-test"
        );
    }

    function test_InitialParticipantsLoaded() public {
        address[] memory participants = lottery.getParticipants();
        assertEq(participants.length, 2);
        assertEq(participants[0], user1);
        assertEq(participants[1], user2);
    }

    function test_StateIsPending() public {
        assertEq(uint(lottery.lotteryState()), uint(LotteryClosed.State.Pending));
    }

    function test_AddParticipantsBatchOnlyCreator() public {
        vm.prank(creator);
        address ;
        more[0] = user3;
        lottery.addParticipantsBatch(more);

        address[] memory participants = lottery.getParticipants();
        assertEq(participants.length, 3);
        assertEq(participants[2], user3);
    }

    function test_RevertIfNonCreatorAdds() public {
        vm.prank(user1);
        address ;
        more[0] = user3;

        vm.expectRevert(Errors.NotCreator.selector);
        lottery.addParticipantsBatch(more);
    }
}
