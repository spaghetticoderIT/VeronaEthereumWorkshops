const Web3 = require("web3");
const fs = require("fs");

const infuraApiKey = JSON.parse(fs.readFileSync("infura.json", "utf8")).apiKey;

const web3 = new Web3();
web3.setProvider(
  new web3.providers.HttpProvider(
    "https://mainnet.infura.io/v3/" + infuraApiKey
  )
);

web3.eth.getBlock("latest").then(console.log);
