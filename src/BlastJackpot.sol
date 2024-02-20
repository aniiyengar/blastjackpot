// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract BlastJackpot {
    event Result(
        string resultType,
        uint256 returnedAmount
    );

    function rollNumber(uint256 maximum) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % maximum;
    }

    function flipETH() payable public returns (string memory) {
        uint256 amountLessFees = msg.value * 100 / 105;

        // the minimum roll is 0.005 ether
        require(amountLessFees >= 0.005 ether, "Minimum roll is 0.005 ether");

        uint256 potentialWinnings = amountLessFees * 2;
        uint256 jackpot = address(this).balance;

        if (address(this).balance < potentialWinnings) {
            uint256 randomNumber = rollNumber(1000);

            if (randomNumber == 1) {
                emit Result("jackpot", jackpot);
                payable(msg.sender).transfer(jackpot);
                return "jackpot";
            } else {
                emit Result("rugged", 0);
                return "rugged";
            }
        } else {
            uint256 randomNumber = rollNumber(2000);

            if (randomNumber == 1) {
                emit Result("jackpot", jackpot);
                payable(msg.sender).transfer(jackpot);
                return "jackpot";
            } else if (randomNumber <= 1000) {
                emit Result("doubled", potentialWinnings);
                payable(msg.sender).transfer(potentialWinnings);
                return "doubled";
            } else {
                emit Result("rugged", 0);
                return "rugged";
            }
        }
    }

    function flipERC20(address tokenAddress) public returns (string memory) {
        uint256 amount = IERC20(tokenAddress).balanceOf(msg.sender);
        require(amount > 0, "You don't have any tokens");

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        uint256 potentialWinnings = amount * 2;
        uint256 jackpot = IERC20(tokenAddress).balanceOf(address(this));

        if (IERC20(tokenAddress).balanceOf(address(this)) < potentialWinnings) {
            uint256 randomNumber = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            ) % 1000;

            if (randomNumber == 1) {
                emit Result("jackpot", jackpot);
                IERC20(tokenAddress).transfer(msg.sender, jackpot);
                return "jackpot";
            } else {
                emit Result("rugged", 0);
                return "rugged";
            }
        } else {
            uint256 randomNumber = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            ) % 2000;

            if (randomNumber == 1) {
                emit Result("jackpot", jackpot);
                IERC20(tokenAddress).transfer(msg.sender, jackpot);
                return "jackpot";
            } else if (randomNumber <= 1000) {
                emit Result("doubled", potentialWinnings);
                IERC20(tokenAddress).transfer(msg.sender, potentialWinnings);
                return "doubled";
            } else {
                emit Result("rugged", 0);
                return "rugged";
            }
        }
    }
}
