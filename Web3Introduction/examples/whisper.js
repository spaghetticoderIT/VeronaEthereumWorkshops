const Web3 = require("web3");
const web3 = new Web3();

web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

async function getKeys() {
  const sig = await web3.shh.newKeyPair();
  const privateKeyID = sig;
  const pubKey = await web3.shh.getPublicKey(privateKeyID);
  return { sig, privateKeyID, pubKey };
}

async function postMessage(recipientPubKey, sig, topic, message) {
  const messageHash = await web3.shh.post({
    pubKey: recipientPubKey,
    sig: sig,
    ttl: 15,
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
  await postMessage(keys.pubKey, keys.sig, "0x07678231", "Hello World").then(
    console.log
  );
  await receiveMessage(keys.privateKeyID).then(console.log);
}

main();
