var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){
       contractInstance = new web3.eth.Contract(abi, "0xB0d733871C320A14b8c5524AB47A43E9E6a6cA16"
       , {from: accounts[0]});
       console.log(contractInstance);

        contractInstance.events.onBetResult((error, res) => {
            if(error) {
              console.log("Error: " + error);
            } else {
              console.log("Bet Result: " + res);
            }
        });
    });

     $("#heads_button").click(setHeads);
     $("#tails_button").click(setTails);
});

function setHeads() {
  betOn(1);
}

function setTails() {
  betOn(0);
}

function betOn(betOption) {
  var betAmout = $("#bet_amount_input").val();

  var config = {
    value: web3.utils.toWei(betAmout, "ether")
  }

  contractInstance.methods.bet(betOption).send(config)
  .on("transactionHash", function(hash) {
    console.log(hash);
  })
  .on("confirmation", function(confirmationNr){
      console.log(confirmationNr);
  })
  .on("receipt", function(receipt){
      console.log(receipt);
  })
  .then((result) => {
    console.log(result["events"]);



    // console.log("Bet result: " + isWinner);
    //
    // if(isWinner == true) {
    //   $("#name_output").text("You won!");
    // } else {
    //   $("#name_output").text("You lost!");
    // }
  });
}
