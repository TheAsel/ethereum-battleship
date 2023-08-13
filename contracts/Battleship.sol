// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Battleship {
    // ---- Local variables
    address public playerOne;
    address public playerTwo;
    uint256 public agreedBet;
    mapping(address => bytes32) playerTreeRoot;

    // ---- Events
    event GameStart();
    event Error(string error);

    // ---- External functions
    constructor(address creator, uint256 bet) {
        playerOne = creator;
        agreedBet = bet;
    }

    // return the game's creator
    function getGameCreator() external view returns (address) {
        return playerOne;
    }

    // return the game's agreed bet
    function getGameBet() external view returns (uint256) {
        return agreedBet;
    }

    // adds the second player to the game
    function addPlayerTwo(address player) external {
        playerTwo = player;
    }

    // saves the Merkle tree root of the sender
    function commitBoard(bytes32 merkleTreeRoot) external {
        require(playerTreeRoot[msg.sender] == 0, "Board already committed");
        playerTreeRoot[msg.sender] = merkleTreeRoot;
        if (playerTreeRoot[playerOne] != 0 && playerTreeRoot[playerTwo] != 0) {
            emit GameStart();
        }
    }

    // reports the opponent
    function report() external {}
}
