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

    mapping(address => uint256) public erc20MinBets;

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
    function addERC20Whitelist(address tokenAddress, uint256 minBet) public onlyOwner {
        erc20Whitelist[tokenAddress] = true;
        erc20MinBets[tokenAddress] = minBet;
    }

    function removeERC20Whitelist(address tokenAddress) public onlyOwner {
        erc20Whitelist[tokenAddress] = false;
        erc20MinBets[tokenAddress] = 0;
    }

    function withdrawETH(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function withdrawERC20(address tokenAddress, uint256 amount) public onlyOwner {
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function flip(
        uint256 flipAmount,
        uint256 rollMaximum,
        uint256 balance,
        uint256 jackpotAmount
    ) internal view returns (uint256 returnedAmount, string memory resultType) {
        // If we don't have the funds to pay out a 2x win, we just roll
        // for a jackpot
        if (balance < flipAmount) {
            uint256 randomNumber = rollNumber(rollMaximum / 2);

            if (randomNumber == 1) {
                resultType = "jackpot";
                returnedAmount = jackpotAmount;
            } else {
                resultType = "rugged";
                returnedAmount = 0;
            }
        } else {
            uint256 randomNumber = rollNumber(rollMaximum);

            if (randomNumber == 1) {
                resultType = "jackpot";
                returnedAmount = jackpotAmount;
            } else if (randomNumber <= rollMaximum / 2) {
                resultType = "doubled";
                returnedAmount = flipAmount * 2;
            } else {
                resultType = "rugged";
                returnedAmount = 0;
            }
        }

        return (returnedAmount, resultType);
    }

    //// MAIN FUNCTIONS //////////////////////////////////////////////////////////
    constructor() Ownable(msg.sender);

    function flipETH() payable public {
        uint256 amountLessFees = msg.value * 100 / 105;

        // the minimum roll is 0.005 ether
        require(amountLessFees >= 0.005 ether, "Minimum roll is 0.005 ether");

        (returnedAmount, resultType) = flip(
            potentialWinnings,
            100000,
            address(this).balance,
            getJackpotETH()
        );

        emit ResultETH(resultType, returnedAmount);

        if (returnedAmount > 0) {
            payable(msg.sender).transfer(returnedAmount);
        }
    }

    function flipERC20(address tokenAddress, uint256 amount) public {
        require(erc20Whitelist[tokenAddress], "Token not whitelisted");

        uint256 amountLessFees = amount * 100 / 105;

        // get decimals for token
        uint8 decimals = IERC20(tokenAddress).decimals();

        require(amountLessFees >= erc20MinBets[tokenAddress], "Paying less than minimum roll");

        (uint256 returnedAmount, string memory resultType) = flip(
            amountLessFees * 2,
            100000,
            IERC20(tokenAddress).balanceOf(address(this)),
            getJackpotERC20(tokenAddress)
        );

        emit ResultERC20(resultType, returnedAmount, tokenAddress);

        if (returnedAmount > 0) {
            IERC20(tokenAddress).transfer(msg.sender, returnedAmount);
        }
    }

}
