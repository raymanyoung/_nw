var utils = require("./util.js");

var CAL = artifacts.require('./CopyrightedAssetLibrary.sol');
var CALT = artifacts.require('./CopyrightedAssetLibraryToken.sol');
var base = 10 ** 18;

function printAsset(info) {
	console.log("------- asset info ----------");
	console.log("owner: " + info[0]);	
	console.log("create time: " + new Date(info[1].toNumber() * 1000));	
	console.log("hash: " + info[2]);	
	console.log("price: " + info[3].toNumber());	
}

function printLog(result) {
	if (!result.logs) {
		console.log("no log found");
		console.log(result);
		return;
	} 
	var count = result.logs.length;
	for (var i = 0 ; i < count; i++) {
		console.log("-- event: " + result.logs[i].event);
		console.log("---- args: ");
		console.log(result.logs[i].args);
	}
}

function printBalance(result) {

}



contract('CALT:Test', function(accounts) {
//  it('should return a correct string', function(done) {
    //var hello_eth_salon = HelloEthSalon.deployed();

	beforeEach('setup contract for each test', async() => {
		contract = await CAL.deployed(); 
		token = await CALT.deployed();
	
	})

	it('create asset', async() => {
		console.log("price: " + web3.toWei(0.05));
		let result = await contract.createAsset(web3.eth.accounts[1], "abcde", web3.toWei(0.05), {from: web3.eth.accounts[0]});
		printLog(result);	
	});

	it('buy with ETH', async() => {

		let contractOwner = await contract.owner.call();
		console.log('token owner: ' + contractOwner + ' \naccount0:' + web3.eth.accounts[0]);

		let bal = await contract.balanceOf.call(web3.eth.accounts[1]);
		printLog(bal.toNumber());

		console.log("====== before transaction ==========");

		let info = await contract.getAssetInfo.call(0);
		printAsset(info);

		let b1 = web3.eth.getBalance(web3.eth.accounts[1]);
		console.log("account 1 balance " + b1);	

		let b2 = web3.eth.getBalance(web3.eth.accounts[2]);
		console.log("account 2 balance " + b2);	

		await contract.buy.sendTransaction(0, {from: web3.eth.accounts[2], to: token.address, value: web3.toWei(0.1)});		

		console.log("====== after transaction ==========");

		info = await contract.getAssetInfo.call(0);
		printAsset(info);	

		b1 = web3.eth.getBalance(web3.eth.accounts[1]);
		console.log("account 1 balance " + b1);	

		b2 = web3.eth.getBalance(web3.eth.accounts[2]);
		console.log("account 2 balance " + b2);			

		// utils.assertEvent(token, {event: "Transfer"}, function(event) {
		// 	var count = event.length;
		// 	for (var i = 0; i < count; i++) {
		// 		console.log(event[i].args)
		// 	}
		// });


		// utils.assertEvent(token, {event: "Log"}, function(event) {
		// 	var count = event.length;
		// 	for (var i = 0; i < count; i++) {
		// 		console.log(event[i].args)
		// 	}
		// });	
		// utils.assertEvent(contract, {event: "Log"}, function(event) {
		// 	var count = event.length;
		// 	for (var i = 0; i < count; i++) {
		// 		console.log(event[i].args)
		// 	}
		// });		
	});

	it('buy with ERC223', async() => {
		console.log("==========================")

		token.transfer(web3.eth.accounts[1], web3.toWei(1), "");
		console.log("setting asset price to " + 0.02);
		contract.setPrice(0, web3.toWei(0.02), {from: web3.eth.accounts[2]});

		let b1 = await token.balanceOf.call(web3.eth.accounts[1]);
		let b2 = await token.balanceOf.call(web3.eth.accounts[2]);
		console.log("==== balances =====")
		console.log(web3.eth.accounts[1] + ": " + b1.toNumber());
		console.log(web3.eth.accounts[2] + ": " + b2.toNumber());

		console.log("++ setting token address");
		await contract.setSupportedToken(token.address, {from: web3.eth.accounts[1]});

		console.log("++ transferring");
		let re1 = await token.transfer(contract.address, 111111111, web3.fromAscii("0"), {from: web3.eth.accounts[1]});
		printLog(re1);		

		let b3 = await token.balanceOf(web3.eth.accounts[1]);
		let b4 = await token.balanceOf(web3.eth.accounts[2]);
		console.log("==== balances =====")
		console.log(web3.eth.accounts[1] + ": " + b3.toNumber());
		console.log(web3.eth.accounts[2] + ": " + b4.toNumber());
		// console.log("b1: " + b3.toNumber() + "b2: " + b4.toNumber());		

		let info = await contract.getAssetInfo.call(0);
		printAsset(info);	
	});
})
