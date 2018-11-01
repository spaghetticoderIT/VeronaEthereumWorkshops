pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";

contract VeronaCoin is ERC20Mintable {
    string public name = "Verona Coin";
    string public symbol = "VRC";
    uint8 public decimals = 18;
}
