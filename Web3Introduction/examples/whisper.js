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

async function receiveMessage(keyPair, topics) {
  const filter = await web3.shh.newMessageFilter({
    privateKeyID: keyPair,
    topics: topics
  });
  let messages = await web3.shh.getFilterMessages(filter);
  return messages;
}

async function main() {
  const keys = await getKeys();
  const topics = ["0x07678231"];
  const delay = ms => {
    return new Promise(resolve => {
      setTimeout(resolve, ms);
    });
  };
  await postMessage(keys.pubKey, keys.sig, topics[0], "Hello World").then(
    console.log
  );
  await delay(5000);
  await receiveMessage(keys.privateKeyID, topics).then(console.log);
}

main();
