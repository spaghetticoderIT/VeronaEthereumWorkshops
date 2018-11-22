const Web3 = require("web3");
const web3 = new Web3();

web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

async function getKeys() {
  const keyPair = await web3.shh.newKeyPair();
  const privKey = await web3.shh.getPrivateKey(keyPair);
  const pubKey = await web3.shh.getPublicKey(keyPair);
  return { keyPair, privKey, pubKey };
}

async function postMessage(recipientPubKey, topic, message) {
  const messageHash = await web3.shh.post({
    pubKey: recipientPubKey,
    ttl: 50,
    topic: topic,
    powTarget: 0.2,
    powTime: 50,
    payload: web3.utils.fromAscii(message)
  });
  return messageHash;
}

async function receiveMessage(keyPair, topics) {
  const filter = await web3.shh.newMessageFilter({
    privateKeyId: keyPair,
    topics: topics
  });
  let messages = await web3.shh.getFilterMessages(filter);
  return messages;
}

async function main() {
  const keys = await getKeys();
  const topics = ["0x07678231"];
  await postMessage(keys.pubKey, topics[0], "Hello World").then(console.log);
  await receiveMessage(keys.keyPair, topics).then(console.log);
}

main();
