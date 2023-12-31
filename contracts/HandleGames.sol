// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Battleship.sol";

contract HandleGames {
    // ---- Local variables
    // maps a game with its joinable status
    mapping(Battleship => bool) private joinableGames;
    // maps a game with its corresponding index
    mapping(Battleship => uint256) private gamesIndex;
    // array with the addresses of the joinable games
    Battleship[] private gamesArray;
    // nonce used in the random function
    uint256 private nonce;

    // ---- Events
    // emitted when a game is created
    event GameCreated(Battleship gameId, address indexed creator);
    // emitted when a player joins a game
    event GameJoined(Battleship indexed gameId, address indexed player);
    // emitted when a game isn't found
    event GameNotFound(address indexed player);
    // emitted to give a game's info
    event GameInfo(address indexed sender, Battleship indexed gameId);

    // ---- Modifiers
    // requirements for a game to be joinable
    modifier joinable(Battleship game) {
        require(joinableGames[game] == true, "This game isn't joinable");
        require(msg.sender != game.playerOne(), "You created this game");
        _;
    }

    // checks if there are available games
    modifier gamesAvailable() {
        require(gamesArray.length > 0, "No games available");
        _;
    }

    // ---- External functions
    // creates a new game
    function createGame(uint256 bet) external {
        Battleship newGame = new Battleship(msg.sender, bet);
        joinableGames[newGame] = true;
        gamesArray.push(newGame);
        gamesIndex[newGame] = gamesArray.length - 1;
        emit GameCreated(newGame, msg.sender);
    }

    // removes a game from the joinable list
    function joinGame(Battleship game) external joinable(game) {
        game.addPlayerTwo(msg.sender);
        removeGame(game);
        emit GameJoined(game, msg.sender);
    }

    // joins a random game from the list of joinable games
    function getRandomGame() external gamesAvailable {
        uint256 index = random();
        bool found = false;
        for (uint256 i = 0; i < gamesArray.length; i++) {
            Battleship game = gamesArray[(index + i) % gamesArray.length];
            if (game.playerOne() != msg.sender) {
                found = true;
                emit GameInfo(msg.sender, game);
                (game, msg.sender);
                break;
            }
        }
        if (!found) {
            emit GameNotFound(msg.sender);
        }
    }

    // ---- Internal functions
    // removes a game from the list of joinable games
    function removeGame(Battleship game) internal {
        delete joinableGames[game];
        uint256 index = gamesIndex[game];
        if (index == gamesArray.length - 1 || gamesArray.length == 1) {
            gamesArray.pop();
        } else {
            gamesArray[index] = gamesArray[gamesArray.length - 1];
            gamesArray.pop();
            gamesIndex[gamesArray[index]] = index;
        }
        delete gamesIndex[game];
    }

    // returns a random value of gamesArray.lenght
    function random() internal returns (uint256) {
        nonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.prevrandao, block.timestamp, nonce)
                )
            ) % gamesArray.length;
    }
}
