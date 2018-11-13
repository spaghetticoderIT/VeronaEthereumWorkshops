pragma solidity ^0.4.23;

contract HelloWorld {
    function greet() public returns (string) {
        return "Hello World";
    }
}

pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";

contract VeronaEthereumMeetupToken is DetailedERC20, StandardToken {
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _amount) 
    public DetailedERC20(_name, _symbol, _decimals) {
        require(_amount > 0, "amount has to be greater than 0");
        totalSupply_ = _amount.mul(10 ** uint256(_decimals));
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }   
}

var VeronaEthereumMeetupToken = artifacts.require(
  "./VeronaEthereumMeetupToken.sol"
);

module.exports = function(deployer) {
  deployer.deploy(
    VeronaEthereumMeetupToken,
    "VeronaEthereumMeetupToken",
    "VMT",
    18,
    21000000
  );
};
