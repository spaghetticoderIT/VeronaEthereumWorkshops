pragma solidity ^0.4.23;


contract SplitPayment {
    address recipient1;
    address recipient2;

    constructor(address _recipient1, address _recipient2) public {
        recipient1 = _recipient1;
        recipient2 = _recipient2;
    }

    // Fallback
    function() public payable {
        recipient1.send(msg.value / 2);
        recipient2.send(msg.value / 2);
    }
}