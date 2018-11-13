const Web3 = require("web3");
const web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:7545"));

web3.shh
  .post({
    symKeyID:
      "321f3531fad3de1dd8344da26cba1a074ee3689acb796ecb8e5bdf8507b1a0ef", //symKeyID of the sender
    ttl: 10,
    topic: "0x07678231",
    powTarget: 2.01,
    powTime: 2,
    payload: web3.utils.fromAscii("Hello there!")
  })
  .then(function() {
    web3.ssh
      .newMessageFilter({
        privateKeyID: receiver,
        topics: ["0x07678231"]
      })
      .get_new_entries()
      .then(function(message) {
        console.log(message);
      });
  });
