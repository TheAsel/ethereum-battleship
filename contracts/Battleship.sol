// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Battleship {

  // ---- Local variables
  address public playerOne;
  address public playerTwo;

  // ---- External functions
  constructor(address creator) {
    playerOne = creator;
  }

  function addPlayerTwo(address player) external {
    playerTwo = player;
  }
}
