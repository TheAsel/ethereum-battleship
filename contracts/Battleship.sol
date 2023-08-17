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
    address public playerTurn;

    // various phases of the game
    enum Phase {
        Waiting,
        Paying,
        Placing,
        Playing
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

    mapping(address => Shot[]) playerShots;
    mapping(address => mapping(uint8 => bool)) playerShotsMap;
    mapping(address => uint8) playerHits;

    // ---- Events
    // emitted when both players paid the bet
    event BetPayed();
    // emitted when both players placed their ships
    event GameStart();
    // emitted when a player takes a shot
    event ShotTaken(address indexed player);

    // ---- Modifiers
    // checks that the sender is player one or two
    modifier players() {
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
        uint lastIndex = playerShots[opponent].length - 1;
        require(
            playerShots[opponent][lastIndex].index == index,
            "Stored and sent indexes of the shot to confirm don't match"
        );
        require(
            playerShots[opponent][lastIndex].value == Cell.Unconfirm,
            "Invalid cell value"
        );
        if (!merkleVerify(index, ship, salt, proof)) {
            // TODO: proof not verified, opponent wins
            return;
        }
        if (ship) {
            playerShots[opponent][lastIndex].value = Cell.Sunk;
            playerHits[msg.sender]++;
            if (playerHits[msg.sender] == 10) {
                // TODO: all ships sunk, opponent wins
                return;
            }
        } else {
            playerShots[opponent][lastIndex].value = Cell.Miss;
        }
        takeShot(shotIndex);
    }

    // returns the shots taken by a player
    function getPlayerShots(
        address player
    ) external view returns (Shot[] memory) {
        return playerShots[player];
    }

    // reports the opponent
    function report() external players {}

    // ---- Internal functions
    // takes a shot given an index
    function takeShot(uint8 index) internal {
        require(
            !playerShotsMap[msg.sender][index],
            "That cell has already been shot"
        );
        require(index < 64, "Invalid cell index");
        playerShots[msg.sender].push(Shot(index, Cell.Unconfirm));
        playerShotsMap[msg.sender][index] = true;
        playerTurn = playerTurn == playerOne ? playerTwo : playerOne;
        emit ShotTaken(msg.sender);
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
        return MerkleProof.verify(proof, playerTreeRoot[msg.sender], leaf);
    }

    // returns the address of the sender's opponent
    function getOpponent(address sender) internal view returns (address) {
        return sender == playerOne ? playerTwo : playerOne;
    }
}
