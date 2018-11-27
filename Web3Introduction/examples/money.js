const Web3 = require("web3");

const web3 = new Web3();

web3.setProvider(new web3.providers.HttpProvider("http://localhost:7545"));

web3.eth.getAccounts().then(accounts => {
  web3.eth.sendTransaction({
    from: accounts[0],
    to: accounts[1],
    value: web3.utils.toWei("0.05", "ether")
  });
});
