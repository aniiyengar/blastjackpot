// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract BlastJackpot {
    function roll() payable public returns (string memory) {
        // generate a random number between 0 and 199 inclusive
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        ) % 200;

        // the minimum roll is 0.005 ether
        require(msg.value >= 0.005 ether, "Minimum roll is 0.005 ether");

        uint256 potentialWinnings = (msg.value * 199) / 100;

        // if the contract doesn't have funds to pay a winner 1.99x,
        // we need to rug them to maintain consistency. ideally this
        // happens rarely as we maintain a healthy balance.
        if (address(this).balance < potentialWinnings) {
            return "rugged";
        }

        if (randomNumber == 1) {
            // win the jackpot (90% of the contract balance)
            uint256 jackpot = (address(this).balance * 9) / 10;
            payable(msg.sender).transfer(jackpot);
            return "jackpot";
        } else if (randomNumber <= 100) {
            // 2 thru 100 win (almost) double
            // true winnings is 1.99x
            uint256 winnings = potentialWinnings;
            payable(msg.sender).transfer(winnings);
            return "doubled";
        } else {
            // 101 thru 199 get rugged
            return "rugged";
        }
    }
}
