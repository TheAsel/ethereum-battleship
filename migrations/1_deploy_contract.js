const HandleGames = artifacts.require('HandleGames')

module.exports = (deployer) => {
    deployer.deploy(HandleGames);
};