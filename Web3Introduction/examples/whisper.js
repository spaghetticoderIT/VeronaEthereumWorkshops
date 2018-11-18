const Web3 = require("web3");
const web3 = new Web3();

web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

async function getKeys() {
  const symKeyID = await web3.shh.newKeyPair();
  return { symKeyID };
}

async function postMessage(recipientPublicKey, topic, message) {
  const messageHash = await web3.shh.post({
    pubKey: recipientPublicKey,
    ttl: 10,
    topic: topic,
    powTarget: 0.5,
    powTime: 3,
    payload: web3.utils.fromAscii(message)
  });
  return messageHash;
}

async function receiveMessage(keyPair) {
  const filter = await web3.shh.newMessageFilter({
    privateKeyID: keyPair
  });
  let messages = await web3.shh.getFilterMessages(filter);
  return messages;
}

async function main() {
  const keys = await getKeys();
  const publicKey = await web3.shh.getPublicKey(keys.symKeyID);
  await postMessage(publicKey, "0x07678231", "Hello World").then(console.log);
  await receiveMessage(keys.symKeyID).then(console.log);
}

main();
