var utils = require("./util.js");

var CAL = artifacts.require('./CopyrightedAssetLibrary.sol');
var CALT = artifacts.require('./CopyrightedAssetLibraryToken.sol');
var base = 10 ** 18;

function printAsset(info) {
	console.log("create time: " + new Date(info[1].toNumber() * 1000));	
	console.log("price: " + info[2].toNumber());	
	console.log("owner: " + info[0]);	
}

function printLog(result) {
	if (!result.logs) {
		console.log("no log found");
		console.log(result);
		return;
	} 
	var count = result.logs.length;
	for (var i = 0 ; i < count; i++) {
		console.log(result.logs[i].args);
	}
}

contract('CALT:Test', function(accounts) {
//  it('should return a correct string', function(done) {
    //var hello_eth_salon = HelloEthSalon.deployed();

	beforeEach('setup contract for each test', async() => {
		contract = await CAL.deployed(); 
		token = await CALT.deployed();
	})

	it('contract', async() => {
		let contractOwner = await contract.owner.call();
		console.log('token owner: ' + contractOwner + ' \naccount0:' + web3.eth.accounts[0]);

		let result = await contract.createAsset(web3.eth.accounts[1], "abcde", 111, {from: web3.eth.accounts[0]});
//		printLog(result);

		let bal = await contract.balanceOf.call(web3.eth.accounts[1]);
		printLog(bal.toNumber());

		let info = await contract.getAssetInfo.call(0);
		printAsset(info);

		utils.assertEvent(token, {event: "Transfer"}, function(event) {
			var count = event.length;
			for (var i = 0; i < count; i++) {
				console.log(event[i].args)
			}
		});

		// // web3.eth.accounts[0]
		// let result = await token.getVoucher({from: web3.eth.accounts[1]});
		// //console.log(result);
		// //assert.equal(true, result);

		// let newBalance = await token.balanceOf(web3.eth.accounts[1]);
		// console.log('user balance: ' + newBalance.toNumber() / base);

		// let newOwnerBalance = await token.balanceOf(web3.eth.accounts[0]);
		// console.log('owner balance: ' + newOwnerBalance.toNumber() / base);

		// let currentStatus = await token.getStatus.call({from: web3.eth.accounts[1]});
		// printStatus(currentStatus);

		// let burnResult = await token.admire(1, {from: web3.eth.accounts[1], value: base});
		// printLog(burnResult);

		// let newStatus = await token.getStatus.call({from: web3.eth.accounts[1]});
		// printStatus(newStatus);

		// newBalance = await token.balanceOf(web3.eth.accounts[1]);
		// console.log('user balance: ' + newBalance.toNumber() / base);

		// let buyResult = await token.buyToken.sendTransaction({from: web3.eth.accounts[1], to: token.address, value: web3.toWei(1)});		
		// printLog(buyResult);

		// utils.assertEvent(token, {event: "Debug"}, function(event) {
		// 	var count = event.length;
		// 	for (var i = 0; i < count; i++) {
		// 		console.log(event[i].args)
		// 	}
		// });	
			
		// utils.assertEvent(token, {event: "Buy"}, function(event) {
		// 	var count = event.length;
		// 	for (var i = 0; i < count; i++) {
		// 		console.log(event[i].args)
		// 	}
		// });			

		// newBalance = await token.balanceOf(web3.eth.accounts[1]);
		// console.log('user balance: ' + newBalance.toNumber() / base);
	})
})
