const truffleAssert = require("truffle-assertions");
const HandleGames = artifacts.require("HandleGames");
const Battleship = artifacts.require("Battleship");
const StandardMerkleTree =
  require("@openzeppelin/merkle-tree").StandardMerkleTree;

contract("Evaluates the gas cost of a max-length game", (accounts) => {
  let handle;
  let game;
  let address;
  const playerOne = accounts[0];
  const playerTwo = accounts[1];
  const agreedBet = 100;
  let costs = new Array();

  before(async () => {
    handle = await HandleGames.deployed();
  });

  before(async () => {
    const tx = await handle.createGame(agreedBet, { from: playerOne });
    costs.push({ createGame: tx.receipt.gasUsed });
    truffleAssert.eventEmitted(tx, "GameCreated", (data) => {
      address = data.gameId;
      return data.creator == playerOne;
    });
    game = await Battleship.at(address);
  });

  describe("Play a full game", () => {
    it("Get a random game", async () => {
      const tx = await handle.getRandomGame({ from: playerTwo });
      costs.push({ getRandomGame: tx.receipt.gasUsed });
    });

    it("Join a game", async () => {
      const tx = await handle.joinGame(address, { from: playerTwo });
      costs.push({ joinGame: tx.receipt.gasUsed });
    });

    it("Deposit the bet", async () => {
      const tx = await game.depositBet({ from: playerOne, value: agreedBet });
      costs.push({ depositBet: tx.receipt.gasUsed });
      await game.depositBet({ from: playerTwo, value: agreedBet });
    });

    let playerOneTree;
    let playerTwoTree;
    it("Commit the board", async () => {
      const board = [];
      for (let i = 0; i < 64; i++) {
        board.push([i, i < 10, BigInt(i)]);
      }
      playerOneTree = StandardMerkleTree.of(board, [
        "uint8",
        "bool",
        "uint256",
      ]);
      const tx = await game.commitBoard(playerOneTree.root, {
        from: playerOne,
      });
      costs.push({ commitBoard: tx.receipt.gasUsed });
      playerTwoTree = StandardMerkleTree.of(board, [
        "uint8",
        "bool",
        "uint256",
      ]);
      await game.commitBoard(playerTwoTree.root, { from: playerTwo });
    });

    // change this to 10 to test a min-length game instead
    const shotsToTake = 63;
    it("Take 64 shots", async () => {
      let tx = await game.shoot(shotsToTake, { from: playerOne });
      costs.push({ shoot: tx.receipt.gasUsed });
      let confirmAndShootSum = 0;
      for (let i = shotsToTake; i >= 0; i--) {
        value = playerOneTree.values.find((v) => v.value[0] == i).value;
        proof = playerOneTree.getProof(i);
        tx = await game.confirmAndShoot(
          value[0],
          value[1],
          value[2],
          proof,
          i,
          {
            from: playerTwo,
          }
        );
        if (i == shotsToTake) {
          costs.push({ confirmAndShoot: tx.receipt.gasUsed });
        } else {
          confirmAndShootSum += tx.receipt.gasUsed;
        }
        if (i == 0) {
          costs.push({ confirmAndShoot_TOT: confirmAndShootSum });
          break;
        }
        value = playerTwoTree.values.find((v) => v.value[0] == i).value;
        proof = playerTwoTree.getProof(i);
        tx = await game.confirmAndShoot(
          value[0],
          value[1],
          value[2],
          proof,
          i - 1,
          {
            from: playerOne,
          }
        );
        confirmAndShootSum += tx.receipt.gasUsed;
      }
    });

    it("Verify board", async () => {
      const opponentShots = await game.getPlayerShots(playerTwo);
      const all = Array.from(Array(64).keys());
      const { proof, proofFlags, leaves } = playerTwoTree.getMultiProof(
        all.filter((c) => !opponentShots.find((i) => parseInt(i.index) === c))
      );
      const indexes = [];
      const cells = [];
      const salts = [];
      leaves.forEach((i) => {
        indexes.push(i[0]);
        cells.push(i[1]);
        salts.push(BigInt(i[2]));
      });

      const tx = await game.boardCheck(
        indexes,
        cells,
        salts,
        proof,
        proofFlags,
        {
          from: playerOne,
        }
      );
      costs.push({ boardCheck: tx.receipt.gasUsed });
    });

    it("Withdraw", async () => {
      const tx = await game.withdraw({ from: playerOne });
      costs.push({ withdraw: tx.receipt.gasUsed });
    });

    it("Print the gas costs", () => {
      let sum = 0;
      for (var i = 0; i < costs.length; i++) {
        sum += parseInt(Object.values(costs[i]));
      }
      costs.push({ Total: sum });
      console.log("---- MAX LENGTH GAME ----");
      console.log(JSON.parse(JSON.stringify(costs)));
    });
  });
});

contract("Evaluates the gas cost of the report functions", (accounts) => {
  let handle;
  let game;
  let address;
  const playerOne = accounts[0];
  const playerTwo = accounts[1];
  const agreedBet = 100;
  let costs = new Array();

  before(async () => {
    handle = await HandleGames.deployed();
  });

  before(async () => {
    const tx = await handle.createGame(agreedBet, { from: playerOne });
    truffleAssert.eventEmitted(tx, "GameCreated", (data) => {
      address = data.gameId;
      return data.creator == playerOne;
    });
    game = await Battleship.at(address);
  });

  describe("Join a game, then lose to a report", () => {
    it("Get a random game", async () => {
      await handle.getRandomGame({ from: playerTwo });
    });

    it("Join a game", async () => {
      await handle.joinGame(address, { from: playerTwo });
    });

    it("Report opponent", async () => {
      const tx = await game.report({ from: playerOne });
      costs.push({ report: tx.receipt.gasUsed });
    });

    it("Wait for five blocks, then verify", async () => {
      for (let i = 0; i < 5; i++) {
        await handle.createGame(agreedBet, { from: playerOne });
      }
      const tx = await game.verifyReport({ from: playerOne });
      costs.push({ verifyReport: tx.receipt.gasUsed });
    });

    it("Print the gas costs", () => {
      console.log("---- REPORT FUNCTIONS ----");
      console.log(JSON.parse(JSON.stringify(costs)));
    });
  });
});

contract("Evaluates the gas cost of the forfeit function", (accounts) => {
  let handle;
  let game;
  let address;
  const playerOne = accounts[0];
  const playerTwo = accounts[1];
  const agreedBet = 100;
  let costs = new Array();

  before(async () => {
    handle = await HandleGames.deployed();
  });

  before(async () => {
    const tx = await handle.createGame(agreedBet, { from: playerOne });
    truffleAssert.eventEmitted(tx, "GameCreated", (data) => {
      address = data.gameId;
      return data.creator == playerOne;
    });
    game = await Battleship.at(address);
  });

  describe("Join a game, then forfeit", () => {
    it("Get a random game", async () => {
      await handle.getRandomGame({ from: playerTwo });
    });

    it("Join a game", async () => {
      await handle.joinGame(address, { from: playerTwo });
    });

    it("Forfeit", async () => {
      const tx = await game.forfeit({ from: playerOne });
      costs.push({ forfeit: tx.receipt.gasUsed });
    });

    it("Print the gas costs", () => {
      console.log("---- FORFEIT FUNCTION ----");
      console.log(JSON.parse(JSON.stringify(costs)));
    });
  });
});
