pragma solidity 0.5.12;

contract Ownable {
    address public owner;

    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier costs(uint cost) {
      require(msg.value >= cost, "Minimum bet is 0.01 Eth");
      _;
    }

    constructor() public{
        owner = msg.sender;
    }
}
