// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract BlastJackpot {
    event Result(
        string resultType,
        uint256 returnedAmount
    );

    function roll() payable public returns (string memory) {
        // the minimum roll is 0.005 ether
        require(msg.value >= 0.005 ether, "Minimum roll is 0.005 ether");

        uint256 potentialWinnings = msg.value + (msg.value * 99) / 100;
        uint256 jackpot = msg.value + (address(this).balance - msg.value) * 9 / 10;

        // if the contract doesn't have funds to pay a winner 1.99x,
        // we roll a 100-sided die. If it lands on 1, the player wins the jackpot.
        // Otherwise, they get rugged.
        if (address(this).balance < potentialWinnings) {
            // generate a random number between 0 and 100 inclusive
            uint256 randomNumber = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            ) % 100;

            if (randomNumber == 1) {
                emit Result("jackpot", jackpot);
                payable(msg.sender).transfer(jackpot);
                return "jackpot";
            } else {
                emit Result("rugged", 0);
                return "rugged";
            }

        // if the contract has enough funds to pay a winner 1.99x,
        // we roll a 200-sided die. If it lands on 1, the player wins the jackpot.
        // If it lands on 2-100, the player wins 1.99x. Otherwise, they get rugged.
        } else {
            // generate a random number between 0 and 199 inclusive
            uint256 randomNumber = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            ) % 200;

            if (randomNumber == 1) {
                emit Result("jackpot", jackpot);
                payable(msg.sender).transfer(jackpot);
                return "jackpot";
            } else if (randomNumber <= 100) {
                emit Result("doubled", potentialWinnings);
                payable(msg.sender).transfer(potentialWinnings);
                return "doubled";
            } else {
                emit Result("rugged", 0);
                return "rugged";
            }
        }
    }
}
