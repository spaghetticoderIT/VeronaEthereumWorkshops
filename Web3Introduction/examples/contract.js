// Hello world contract usage
const Web3 = require("web3");
const randomString = require("randomstring");
const web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:7545"));

const fs = require("fs");
const abi = JSON.parse(fs.readFileSync("abi.json", "utf8")).abi;
const contractAddress = "0x32fb7a74a9bd7cd87e7f3abc2e655648a7e67c2b";

const contractInstance = new web3.eth.Contract(abi, contractAddress);
const addresses = [];

for (let i = 0; i < 3; i++) {
  addresses.push(web3.eth.accounts.create([randomString.generate()]).address);
}

web3.eth.getAccounts().then(accounts => {
  contractInstance.methods
    .addUser()
    .send({ from: accounts[0] })
    .then(txReceipt => {
      console.log(txReceipt.events.newNumberPushed);
    });
});

contractInstance.methods
  .addUser() // Params here
  .call()
  .then(function(number) {
    console.log("numbers:", number);
  });
