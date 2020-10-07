pragma solidity 0.5.12;

import "./Ownable.sol";
import "./provableAPI.sol";

contract Flip is Ownable, usingProvable {

  uint constant MIN_BET = 0.01 ether;

  uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;

  // contract balance (casino balance?)
  uint public balance;

  // events
  event onBetResult(bool result, string message);
  // event onRandomNumber(uint256 queryId);
  event onRandomFailed(bytes32 queryId);
  // event onFunded(address owner, uint fundingAmount);
  event onBetPlaced(string message, bool result);

  struct Player {
    uint balance;
    bytes32 queryId;
  }

  struct Request {
    address payable userAddress;
    uint headsOrTails;
    bytes32 queryId;
  }

  mapping (bytes32 => Request) public requests;
  mapping (address => Player) public players;

  // event onDebug(string message);

  constructor() public {
    provable_setProof(proofType_Ledger);
  }

  //  -------- OLD PHASE 1 CODE ----------------------------
  // function bet(uint betOption) public payable costs(MIN_BET) returns (bool) {
  //
  //   uint payment = msg.value;
  //   balance += payment;
  //
  //   // get result
  //   bool result = isWinner(betOption, payment);
  //
  //   // fire event on the end
  //   emit onBetResult(result);
  //
  //   return result;
  // }

  function bet(uint betOption) public payable costs(MIN_BET) {
    require(msg.value <= balance, "Available balance is less than the bet amount");

    players[msg.sender].balance += msg.value;

    randomGenerator(betOption);
  }

  function __callback(bytes32 _queryId, string memory _result, bytes memory _proof ) public {

        require(msg.sender == provable_cbAddress());

        if (provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
             emit onRandomFailed(_queryId);
        } else {

          uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;

          if(requests[_queryId].queryId == _queryId && randomNumber == requests[_queryId].headsOrTails) {
            playerWins(_queryId);
            emit onBetResult(true, "You win!");
          } else {
            casinoWins(_queryId);
            emit onBetResult(false, "You lose!");
          }
        }
    }

    function randomGenerator(uint betOption) payable public {
            uint256 QUERY_EXECUTION_DELAY = 0;
            uint256 GAS_FOR_CALLBACK = 200000;

            bytes32 _queryId = provable_newRandomDSQuery(
                QUERY_EXECUTION_DELAY,
                NUM_RANDOM_BYTES_REQUESTED,
                GAS_FOR_CALLBACK
            );

            requests[_queryId].userAddress = msg.sender;
            requests[_queryId].queryId = _queryId;
            requests[_queryId].headsOrTails = betOption;
            players[msg.sender].queryId = _queryId;

            emit onBetPlaced("Bet placed, waiting for result", true);
    }

    function playerWins(bytes32 _queryId) private returns(uint) {
       uint playerBalance = players[requests[_queryId].userAddress].balance * 2;
       balance -= players[requests[_queryId].userAddress].balance;
       players[requests[_queryId].userAddress].balance = 0;

       requests[_queryId].userAddress.transfer(playerBalance);

       return players[requests[_queryId].userAddress].balance;
   }

   function casinoWins(bytes32 _queryId) private returns(uint) {
       balance += players[requests[_queryId].userAddress].balance;
       players[requests[_queryId].userAddress].balance = 0;

       return balance;
   }

   function setBalance() public payable onlyOwner {
           balance += msg.value;
   }

  // function getBalance() public view returns (uint) {
  //   uint currentBalance = address(this).balance;
  //   return currentBalance;
  // }

// PSEUDO NUMBER GENERATOR
  function random() private view returns (bool) {
    uint res = now % 2;
    if(res == 0) {
      return false;
    }
    return true;
  }
}
