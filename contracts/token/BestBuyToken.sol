pragma solidity ^0.4.17;

import "./MintableToken.sol";
import "./DetailedERC20.sol";

contract BestBuyToken is DetailedERC20, MintableToken {

    function BestBuyToken(string _name, string _symbol, uint8 _decimals) DetailedERC20(_name, _symbol, _decimals) public {
        owner = msg.sender;
    }
}
