// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Battleship {
    // ---- Local constants
    // number of cells in the board (default: 8 * 8 = 64)
    uint8 constant BOARD_SIZE = 64;
    // number of ships for each player (default: 10)
    uint8 constant SHIP_COUNT = 10;
    // number of mined blocks before a reported player loses
    uint8 constant DELAY = 5;

    // ---- Local variables
    address public playerOne;
    address public playerTwo;
    uint256 public agreedBet;
    address public playerTurn;
    address public winner;
    address public verifiedWinner;
    uint256 timeout;

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
        bool reported;
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
    event GameWon();
    // emitted when the winner is verified
    event WinnerVerified();
    // emitted when a player is reported
    event PlayerReported(address indexed player);
    // emitted when a reported player made a move in time
    event PlayerMoved(address indexed player);

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

    // checks if you can report your opponent at this time
    modifier canReport() {
        _canReport();
        _;
    }

    // checks if a reported player made a move before the timeout
    modifier makeMove() {
        _makeMove();
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
    function depositBet() external payable isPlayer payingPhase makeMove {
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
    ) external isPlayer placingPhase makeMove {
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
    function shoot(uint8 index) external isPlayerTurn playingPhase makeMove {
        takeShot(index);
    }

    // confirms a hit/miss of the opponent and then shoots
    function confirmAndShoot(
        uint8 index,
        bool ship,
        uint256 salt,
        bytes32[] memory proof,
        uint8 shotIndex
    ) external isPlayerTurn playingPhase makeMove {
        address opponent = getOpponent(msg.sender);
        uint256 lastIndex = players[opponent].shots.length - 1;
        require(
            players[opponent].shots[lastIndex].index == index,
            "Stored and sent indexes of the shot to confirm don't match"
        );
        require(
            players[opponent].shots[lastIndex].value == Cell.Unconfirm,
            "Invalid cell value"
        );
        if (!merkleVerify(index, ship, salt, proof)) {
            winner = opponent;
            declareWinner(opponent);
            return;
        }
        if (ship) {
            players[opponent].shots[lastIndex].value = Cell.Sunk;
            players[msg.sender].hits++;
            if (players[msg.sender].hits == SHIP_COUNT) {
                winner = opponent;
                gamePhase = Phase.Verifying;
                emit GameWon();
                return;
            }
        } else {
            players[opponent].shots[lastIndex].value = Cell.Miss;
        }
        takeShot(shotIndex);
    }

    // verifies the cells of the winner's board that haven't been shot
    function boardCheck(
        uint8[] memory indexes,
        bool[] memory cells,
        uint256[] memory salts,
        bytes32[] memory proof,
        bool[] memory proofFlags
    ) external verifyingPhase makeMove {
        require(msg.sender == winner, "Only the winner can send the board");
        require(
            indexes.length == cells.length,
            "Must send all indexes, cells and salts"
        );
        require(
            indexes.length == salts.length,
            "Must send all indexes, cells and salts"
        );
        address opponent = getOpponent(msg.sender);
        if (
            !merkleMultiVerify(
                proof,
                proofFlags,
                players[msg.sender].treeRoot,
                indexes,
                cells,
                salts
            )
        ) {
            declareWinner(opponent);
            return;
        }
        // board checks, if something is wrong the opponent wins by default
        uint8 ships = 0;
        for (uint8 i = 0; i < indexes.length; i++) {
            // checks the validity of the indexes
            if (indexes[i] >= BOARD_SIZE) {
                declareWinner(opponent);
                return;
            }
            // checks that all the opponent's shots have been registered
            if (players[opponent].shotsMap[indexes[i]]) {
                declareWinner(opponent);
                return;
            }
            // ticks the verified cells
            players[opponent].shotsMap[indexes[i]] = true;
            // counts the ships missed by the opponent
            if (cells[i]) {
                ships++;
            }
        }
        // checks that every cell has been verified
        for (uint8 i = 0; i < BOARD_SIZE; i++) {
            if (!players[opponent].shotsMap[i]) {
                declareWinner(opponent);
                return;
            }
        }
        // checks that the correct number of ships was placed
        if (players[msg.sender].hits + ships == SHIP_COUNT) {
            declareWinner(msg.sender);
        } else {
            declareWinner(opponent);
        }
    }

    // returns the shots taken by a player
    function getPlayerShots(
        address player
    ) external view returns (Shot[] memory) {
        return players[player].shots;
    }

    // reports the opponent for inactivity
    function report() external isPlayer canReport {
        address opponent = getOpponent(msg.sender);
        require(
            !players[opponent].reported,
            "You already reported your opponent"
        );
        players[opponent].reported = true;
        timeout = block.number + DELAY;
        emit PlayerReported(opponent);
    }

    // checks if the reported player made a move
    function verifyReport() external isPlayer canReport {
        address opponent = getOpponent(msg.sender);
        require(players[opponent].reported, "You didn't report your opponent");
        if (block.number >= timeout) {
            winner = msg.sender;
            declareWinner(msg.sender);
        } else {
            players[opponent].reported = false;
            emit PlayerMoved(opponent);
        }
    }

    // forfeits the game
    function forfeit() external isPlayer {
        address opponent = getOpponent(msg.sender);
        winner = opponent;
        declareWinner(opponent);
    }

    // transfers the contract's balance to the winner's wallet
    function withdraw() external withdrawPhase {
        require(
            msg.sender == verifiedWinner,
            "Only the winner can withdraw the prize"
        );
        gamePhase = Phase.End;
        payable(msg.sender).transfer(address(this).balance);
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

    // multiproof that verifies the values are contained in the tree
    function merkleMultiVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        uint8[] memory indexes,
        bool[] memory cells,
        uint256[] memory salts
    ) internal pure returns (bool) {
        bytes32[] memory leaves = new bytes32[](indexes.length);
        for (uint8 i = 0; i < leaves.length; i++) {
            leaves[i] = keccak256(
                bytes.concat(
                    keccak256(abi.encode(indexes[i], cells[i], salts[i]))
                )
            );
        }
        return MerkleProof.multiProofVerify(proof, proofFlags, root, leaves);
    }

    // returns the address of the sender's opponent
    function getOpponent(address sender) internal view returns (address) {
        return sender == playerOne ? playerTwo : playerOne;
    }

    // sets player as the game's winner
    function declareWinner(address player) internal {
        verifiedWinner = player;
        gamePhase = Phase.Withdraw;
        emit WinnerVerified();
    }

    // wrapped the modifiers with internal functions to reduce code size when deploying
    function _canReport() private view {
        address opponent = getOpponent(msg.sender);
        require(
            !players[msg.sender].reported,
            "Can't report if you're reported yourself"
        );
        require(
            gamePhase != Phase.Waiting &&
                gamePhase != Phase.Withdraw &&
                gamePhase != Phase.End,
            "Can't report in this phase of the game"
        );
        if (gamePhase == Phase.Paying) {
            require(
                !players[opponent].payedBet,
                "Can't report, your opponent already deposited"
            );
        } else if (gamePhase == Phase.Placing) {
            require(
                players[opponent].treeRoot == 0,
                "Can't report, your opponent's board was already committed"
            );
        } else if (gamePhase == Phase.Playing) {
            require(playerTurn == opponent, "Can't report, it's your turn");
        } else if (gamePhase == Phase.Verifying) {
            require(
                winner == opponent,
                "Can't report, you have to send your board"
            );
        }
    }

    function _makeMove() private {
        if (players[msg.sender].reported) {
            if (block.number < timeout) {
                players[msg.sender].reported = false;
                emit PlayerMoved(msg.sender);
            } else if (block.number >= timeout) {
                winner = msg.sender == playerOne ? playerTwo : playerOne;
                declareWinner(winner);
                return;
            }
        }
    }
}
