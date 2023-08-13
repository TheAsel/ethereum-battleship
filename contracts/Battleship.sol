// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Battleship {
    // ---- Local variables
    address public playerOne;
    address public playerTwo;
    uint256 public agreedBet;

    // ---- Events
    event Error(string error);

    // ---- External functions
    constructor(address creator, uint256 bet) {
        playerOne = creator;
        agreedBet = bet;
    }

    function getGameCreator() external view returns (address) {
        return playerOne;
    }

    function getGameBet() external view returns (uint256) {
        return agreedBet;
    }

    function addPlayerTwo(address player) external {
        playerTwo = player;
    }
}
