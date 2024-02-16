// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/BlastJackpot.sol";

contract BlastJackpotTest is Test {
    BlastJackpot blastJackpot;

    function setUp() public {
        blastJackpot = new BlastJackpot();
    }

    function test_roll() public {
      hoax(0x4C5F8Fe7B48ff73f54242e70337221cFD74FD44b, 100 ether);
      blastJackpot.roll{value: 0.005 ether}();
    }
}
