// Hello world contract usage
const Web3 = require("web3");
const web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:7545"));

const fs = require("fs");
const abi = JSON.parse(fs.readFileSync("abi.json", "utf8")).abi;
const contractAddress = "0x1a6bbc4f4759053a3eac90ecf2b8458c26c6420f";

const contractInstance = new web3.eth.Contract(abi, contractAddress);

contractInstance.methods
  .greet() // Params here
  .call()
  .then(function(message) {
    console.log(message);
  });
