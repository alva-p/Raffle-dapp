// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILottery {
    function creator() external view returns (address);
    function lotteryState() external view returns (uint8);
    function getWinners() external view returns (address[] memory);
}

/// @title EmergencyWithdraw - Contract to recover funds from lottery
contract EmergencyWithdraw {
    
    /// @notice Extract all ETH from a lottery contract (only for creator/winner)
    /// @param lotteryContract Address of the lottery contract
    function extractFunds(address payable lotteryContract) external {
        ILottery lottery = ILottery(lotteryContract);
        
        // Verify caller is creator
        require(lottery.creator() == msg.sender, "Not creator");
        
        // Verify lottery is completed
        require(lottery.lotteryState() == 4, "Lottery not completed"); // State.Completed = 4
        
        // Get winners
        address[] memory winners = lottery.getWinners();
        bool isWinner = false;
        for (uint256 i = 0; i < winners.length; i++) {
            if (winners[i] == msg.sender) {
                isWinner = true;
                break;
            }
        }
        require(isWinner, "Not a winner");
        
        // Extract all ETH
        uint256 balance = lotteryContract.balance;
        require(balance > 0, "No funds to extract");
        
        (bool success, ) = lotteryContract.call{value: 0}("");
        require(success, "Call failed");
        
        // Transfer ETH to winner
        (bool sent, ) = payable(msg.sender).call{value: balance}("");
        require(sent, "Transfer failed");
    }
    
    receive() external payable {}
}