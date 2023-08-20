<div align="center">
  <h1>Playing Battleship on Ethereum</h1>
</div>

## Project objective

The project required the implementation of the Battleship game on the Ethereum blockchain, so that the properties of the blockchain, i.e. tamper-freeness, the possibility of auditing the fair rules of the game, encoded in smart contracts, instant and secure reward payments, and secure rewarding implementation, could be exploited. Furthermore, implementing the game on a permissionless blockchain implies that participating in the game cannot be prevented from anyone, since there is no censoring authority.

## Usage

To use this project, first download its latest [release](https://github.com/TheAsel/ethereum-battleship/releases). Then:

1. start a local blockchain instance with Ganache UI, port 7545
2. from inside the ethereum-battleship/ folder, run ``npm ci`` and then ``truffle migrate``
3. from inside the ethereum-battleship/frontend/ folder, run ``npm ci`` and then ``npm run dev``

This will automatically open the webpage in a browser. Open the same page in a different browser to play locally. In both browsers you'll need to setup a different MetaMask account on the correct network.

## Tests

To evaluate the gas cost, run ``truffle test`` from inside the ethereum-battleship/ folder. The outputs will be printed in the console.

## Documentation

Please see the [project report](https://github.com/TheAsel/ethereum-battleship/blob/main/report.pdf) for the design choices, gas evaluation, potential vulnerabilities and user manual.
