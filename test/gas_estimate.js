const truffleAssert = require("truffle-assertions");
const HandleGames = artifacts.require("HandleGames");
const Battleship = artifacts.require("Battleship");
const StandardMerkleTree =
  require("@openzeppelin/merkle-tree").StandardMerkleTree;

contract(
  "Calculates the gas cost of the contracts' functions",
  (accounts) => {}
);
