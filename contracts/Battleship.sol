// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Battleship {
    // ---- Local variables
    address public playerOne;
    address public playerTwo;
    uint256 public agreedBet;
    mapping(address => bool) payedBet;
    mapping(address => bytes32) playerTreeRoot;

    // various phases of the game
    enum Phase {
        Waiting,
        Paying,
        Placing,
        Playing
    }

    // the current phase of the game
    Phase public gamePhase;

    // ---- Events
    // emitted when both players paid the bet
    event BetPayed();
    // emitted when both players placed their ships
    event GameStart();
    // emitted when there is an error
    event Error(string error);

    // ---- Modifiers
    // checks that the sender is player one or two
    modifier players() {
        require(
            msg.sender == playerOne || msg.sender == playerTwo,
            "You aren't a player of this game"
        );
        _;
    }

    // checks for the various game's phases
    modifier waitingPhase() {
        require(
            gamePhase == Phase.Waiting,
            "This game isn't in the waiting phase"
        );
        _;
    }

    modifier payingPhase() {
        require(
            gamePhase == Phase.Paying,
            "This game isn't in the paying phase"
        );
        _;
    }

    modifier placingPhase() {
        require(
            gamePhase == Phase.Placing,
            "This game isn't in the placing phase"
        );
        _;
    }

    modifier playingPhase() {
        require(
            gamePhase == Phase.Playing,
            "This game isn't in the playing phase"
        );
        _;
    }

    // ---- External functions
    constructor(address creator, uint256 bet) {
        playerOne = creator;
        agreedBet = bet;
        gamePhase = Phase.Waiting;
    }

    // return the game's creator
    function getGameCreator() external view waitingPhase returns (address) {
        return playerOne;
    }

    // return the game's agreed bet
    function getGameBet() external view waitingPhase returns (uint256) {
        return agreedBet;
    }

    // adds the second player to the game
    function addPlayerTwo(address player) external waitingPhase {
        playerTwo = player;
        gamePhase = Phase.Paying;
    }

    // deposits the agreed bet and adds the second player
    function depositBet() external payable players payingPhase {
        require(!payedBet[msg.sender], "Bet already deposited");
        require(msg.value == agreedBet, "Must pay the agreed amount");
        payedBet[msg.sender] = true;
        if (payedBet[playerOne] && payedBet[playerTwo]) {
            gamePhase = Phase.Placing;
            emit BetPayed();
        }
    }

    // saves the Merkle tree root of the sender
    function commitBoard(bytes32 merkleTreeRoot) external players placingPhase {
        require(playerTreeRoot[msg.sender] == 0, "Board already committed");
        playerTreeRoot[msg.sender] = merkleTreeRoot;
        if (playerTreeRoot[playerOne] != 0 && playerTreeRoot[playerTwo] != 0) {
            gamePhase = Phase.Playing;
            emit GameStart();
        }
    }

    // reports the opponent
    function report() external players {}
}
