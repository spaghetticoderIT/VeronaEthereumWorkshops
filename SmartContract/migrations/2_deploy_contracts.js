const VeronaCoin = require("../contracts/VeronaCoin.sol");
const VeronaCoinCrowdsale = require("../contracts/VeronaCoinCrowdsale.sol");

module.exports = function(deployer, network, accounts) {
  const openingTime = web3.eth.getBlock("latest").timestamp + 2; // two secs in the future
  const closingTime = openingTime + 86400 * 30; // 30 days
  const rate = new web3.BigNumber(1000);
  const wallet = accounts[1];

  return deployer
    .then(() => {
      return deployer.deploy(VeronaCoin);
    })
    .then(() => {
      return deployer.deploy(
        VeronaCoinCrowdsale,
        openingTime,
        closingTime,
        rate,
        wallet,
        VeronaCoin.address
      );
    });
};
