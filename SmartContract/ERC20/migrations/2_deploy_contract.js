var VeronaEthereumMeetupToken = artifacts.require(
  "./VeronaEthereumMeetupToken.sol"
);

module.exports = function(deployer) {
  deployer.deploy(
    VeronaEthereumMeetupToken,
    "VeronaEthereumMeetupToken",
    "VMT",
    18,
    21000000
  );
};
