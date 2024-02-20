// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlastJackpot is Ownable {

    //// EVENTS //////////////////////////////////////////////////////////////////
    event ResultETH(
        string resultType,
        uint256 returnedAmount
    );

    event ResultERC20(
        string resultType,
        uint256 returnedAmount,
        address tokenAddress
    );

    //// STATE VARIABLES /////////////////////////////////////////////////////////
    mapping(address => bool) public erc20Whitelist;

    //// HELPER FUNCTIONS ////////////////////////////////////////////////////////
    function rollNumber(uint256 maximum) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % maximum;
    }

    function getJackpotETH() public view returns (uint256) {
        return address(this).balance * 90 / 100;
    }

    function getJackpotERC20(address tokenAddress) public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this)) * 90 / 100;
    }

    //// ADMIN FUNCTIONS /////////////////////////////////////////////////////////
    function setERC20Whitelist(address tokenAddress, bool status) public onlyOwner {
        erc20Whitelist[tokenAddress] = status;
    }

    function withdrawETH(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function withdrawERC20(address tokenAddress, uint256 amount) public onlyOwner {
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    //// MAIN FUNCTIONS //////////////////////////////////////////////////////////
    constructor() Ownable(msg.sender);

    function flipETH() payable public {
        uint256 amountLessFees = msg.value * 100 / 105;

        // the minimum roll is 0.005 ether
        require(amountLessFees >= 0.005 ether, "Minimum roll is 0.005 ether");

        uint256 potentialWinnings = amountLessFees * 2;
        uint256 jackpot = getJackpotETH();

        if (address(this).balance < potentialWinnings) {
            uint256 randomNumber = rollNumber(10000);

            if (randomNumber == 69) {
                emit ResultETH("jackpot", jackpot);
                payable(msg.sender).transfer(jackpot);
            } else {
                emit ResultETH("rugged", 0);
            }
        } else {
            uint256 randomNumber = rollNumber(20000);

            if (randomNumber == 69) {
                emit ResultETH("jackpot", jackpot);
                payable(msg.sender).transfer(jackpot);
            } else if (randomNumber <= 10000) {
                emit ResultETH("doubled", potentialWinnings);
                payable(msg.sender).transfer(potentialWinnings);
            } else {
                emit ResultETH("rugged", 0);
            }
        }
    }

    function flipERC20(address tokenAddress, uint256 amount) public {
        require(erc20Whitelist[tokenAddress], "Token not whitelisted");

        uint256 amountLessFees = amount * 100 / 105;

        // get decimals for token
        uint8 decimals = IERC20(tokenAddress).decimals();

        // the minimum roll is 0.005 tokens
        require(amountLessFees >= 5 * 10 ** decimals, "Minimum roll is 5 tokens");

        // transfer tokens to contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        uint256 potentialWinnings = amountLessFees * 2;
        uint256 jackpot = getJackpotERC20(tokenAddress);

        if (IERC20(tokenAddress).balanceOf(address(this)) < potentialWinnings) {
            // we don't have the funds to pay a regular win, so we just try to roll
            // for a jackpot
            uint256 randomNumber = rollNumber(10000);

            if (randomNumber == 69) {
                emit ResultERC20("jackpot", jackpot, tokenAddress);
                IERC20(tokenAddress).transfer(msg.sender, jackpot);
            } else {
                emit ResultERC20("rugged", 0, tokenAddress);
            }
        } else {
            uint256 randomNumber = rollNumber(20000);

            if (randomNumber == 69) {
                emit ResultERC20("jackpot", jackpot, tokenAddress);
                IERC20(tokenAddress).transfer(msg.sender, jackpot);
            } else if (randomNumber <= 10000) {
                emit ResultERC20("doubled", potentialWinnings, tokenAddress);
                IERC20(tokenAddress).transfer(msg.sender, potentialWinnings);
            } else {
                emit ResultERC20("rugged", 0, tokenAddress);
            }
        }
    }

}
