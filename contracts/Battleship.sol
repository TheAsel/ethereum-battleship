// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Battleship {
    // ---- Local constants
    // number of cells in the board (default: 8 * 8 = 64)
    uint8 constant BOARD_SIZE = 64;
    // number of ships for each player (default: 10)
    uint8 constant SHIP_COUNT = 10;

    // ---- Local variables
    address public playerOne;
    address public playerTwo;
    uint256 public agreedBet;
    address public playerTurn;
    address public winner;
    address public verifiedWinner;

    // various phases of the game
    enum Phase {
        Waiting,
        Paying,
        Placing,
        Playing,
        Verifying,
        Withdraw,
        End
    }

    // the current phase of the game
    Phase public gamePhase;

    // possible values of a cell
    enum Cell {
        None,
        Unconfirm,
        Sunk,
        Miss
    }

    struct Shot {
        uint8 index;
        Cell value;
    }

    // player's information
    struct Player {
        bool payedBet;
        bytes32 treeRoot;
        Shot[] shots;
        mapping(uint8 => bool) shotsMap;
        uint8 hits;
    }

    mapping(address => Player) players;

    // ---- Events
    // emitted when both players paid the bet
    event BetPayed();
    // emitted when both players placed their ships
    event GameStart();
    // emitted when a player takes a shot
    event ShotTaken();
    // emitted when the game is won by someone
    event Won();
    // emitted when the winner is verified
    event WinnerVerified();

    // ---- Modifiers
    // checks that the sender is player one or two
    modifier isPlayer() {
        require(
            msg.sender == playerOne || msg.sender == playerTwo,
            "You aren't a player of this game"
        );
        _;
    }

    // checks if it's the message sender's turn
    modifier isPlayerTurn() {
        require(msg.sender == playerTurn);
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

    modifier verifyingPhase() {
        require(
            gamePhase == Phase.Verifying,
            "This game isn't in the verifying phase"
        );
        _;
    }

    modifier withdrawPhase() {
        require(
            gamePhase == Phase.Withdraw,
            "This game isn't in the withdraw phase"
        );
        _;
    }

    // ---- External functions
    // contract constructor
    constructor(address creator, uint256 bet) {
        playerOne = creator;
        agreedBet = bet;
        gamePhase = Phase.Waiting;
    }

    // adds the second player to the game
    function addPlayerTwo(address player) external waitingPhase {
        playerTwo = player;
        gamePhase = Phase.Paying;
    }

    // deposits the agreed bet and adds the second player
    function depositBet() external payable isPlayer payingPhase {
        require(!players[msg.sender].payedBet, "Bet already deposited");
        require(msg.value == agreedBet, "Must pay the agreed amount");
        players[msg.sender].payedBet = true;
        if (players[playerOne].payedBet && players[playerTwo].payedBet) {
            gamePhase = Phase.Placing;
            emit BetPayed();
        }
    }

    // saves the Merkle tree root of the sender
    function commitBoard(
        bytes32 merkleTreeRoot
    ) external isPlayer placingPhase {
        require(players[msg.sender].treeRoot == 0, "Board already committed");
        players[msg.sender].treeRoot = merkleTreeRoot;
        if (
            players[playerOne].treeRoot != 0 && players[playerTwo].treeRoot != 0
        ) {
            gamePhase = Phase.Playing;
            playerTurn = playerOne;
            emit GameStart();
        }
    }

    // first shot, nothing to confirm
    function shoot(uint8 index) external isPlayerTurn playingPhase {
        takeShot(index);
    }

    // confirms a hit/miss of the opponent and then shoots
    function confirmAndShoot(
        uint8 index,
        bool ship,
        uint256 salt,
        bytes32[] memory proof,
        uint8 shotIndex
    ) external isPlayerTurn playingPhase {
        address opponent = getOpponent(msg.sender);
        uint lastIndex = players[opponent].shots.length - 1;
        require(
            players[opponent].shots[lastIndex].index == index,
            "Stored and sent indexes of the shot to confirm don't match"
        );
        require(
            players[opponent].shots[lastIndex].value == Cell.Unconfirm,
            "Invalid cell value"
        );
        if (!merkleVerify(index, ship, salt, proof)) {
            declareWinner(opponent);
            return;
        }
        if (ship) {
            players[opponent].shots[lastIndex].value = Cell.Sunk;
            players[msg.sender].hits++;
            if (players[msg.sender].hits == SHIP_COUNT) {
                winner = opponent;
                gamePhase = Phase.Verifying;
                emit Won();
                return;
            }
        } else {
            players[opponent].shots[lastIndex].value = Cell.Miss;
        }
        takeShot(shotIndex);
    }

    // returns the shots taken by a player
    function getPlayerShots(
        address player
    ) external view returns (Shot[] memory) {
        return players[player].shots;
    }

    // reports the opponent
    function report() external isPlayer {}

    // forfeits the game
    function forfeit() external isPlayer {
        address opponent = getOpponent(msg.sender);
        declareWinner(opponent);
    }

    // ---- Internal functions
    // takes a shot given an index
    function takeShot(uint8 index) internal {
        require(
            !players[msg.sender].shotsMap[index],
            "That cell has already been shot"
        );
        require(index < BOARD_SIZE, "Invalid cell index");
        players[msg.sender].shots.push(Shot(index, Cell.Unconfirm));
        players[msg.sender].shotsMap[index] = true;
        playerTurn = playerTurn == playerOne ? playerTwo : playerOne;
        emit ShotTaken();
    }

    // verifies that the value is contained in the tree
    function merkleVerify(
        uint8 index,
        bool ship,
        uint256 salt,
        bytes32[] memory proof
    ) internal view returns (bool) {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(index, ship, salt)))
        );
        return MerkleProof.verify(proof, players[msg.sender].treeRoot, leaf);
    }

    // returns the address of the sender's opponent
    function getOpponent(address sender) internal view returns (address) {
        return sender == playerOne ? playerTwo : playerOne;
    }

    // sets player as the game's winner
    function declareWinner(address player) internal {
        winner = player;
        verifiedWinner = player;
        gamePhase = Phase.Withdraw;
        emit WinnerVerified();
    }
}
