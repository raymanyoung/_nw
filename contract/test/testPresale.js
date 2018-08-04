var utils = require("./util.js");
const expectThrow = require('./expectThrow.js');

var NWT = artifacts.require('./NeoWorldToken.sol');
var ROA = artifacts.require('./ROA.sol');
var ROB = artifacts.require('./ROB.sol');

const web3Abi = require('web3-eth-abi');


const overloadedTransferAbi = {
    "constant": false,
    "inputs": [
        {
            "name": "_to",
            "type": "address"
        },
        {
            "name": "_value",
            "type": "uint256"
        }
    ],
    "name": "transfer",
    "outputs": [
        {
            "name": "",
            "type": "bool"
        }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
};

contract('NWT:Test', function(accounts) {
	beforeEach('setup contract for each test', async() => {
		nwt = await NWT.deployed(); 
		roa = await ROA.deployed();
		rob = await ROB.deployed();
	});

	it('adding removing token', async() => {
		console.log("Adding first token");
		var result = await nwt.addSupportedToken(roa.address, web3.toWei(500), Date.now() / 1000, Date.now() / 1000 + 1000000);

		console.log("getting supported tokens");
		var result1 = await nwt.getSupportedTokens();
		console.log(result1);

		console.log("getting first token status");
		var result2 = await nwt.getTokenStatus(result1[0]);
		console.log(result2);
		console.log(web3.fromWei(result2[2]).toNumber());

		await expectThrow(function() {
			return nwt.addSupportedToken(roa.address, web3.toWei(500), Date.now() / 1000, Date.now() / 1000 + 1000000);
		});


		var result6 =  await nwt.addSupportedToken(rob.address, web3.toWei(500), Date.now() / 1000, Date.now() / 1000 + 1000000);
		var result7 = await nwt.getSupportedTokens();
		console.log(result7);

		var result8 = await nwt.removeSupportedToken(rob.address);
		var result9 = await nwt.getSupportedTokens();
		console.log(result9);

	});
	it ('do presale', async() => {
		console.log("test account: " + web3.eth.accounts[1]);
		console.log("transfer ROA");
		await roa.transfer(nwt.address, 100000);
		
		var r = await web3Abi.encodeFunctionCall(
            overloadedTransferAbi,
            [
                web3.eth.accounts[1],
                web3.toWei(2000000),
            ]
        );
		let re1 =  web3.eth.sendTransaction({from: web3.eth.accounts[0], to: nwt.address, data: r});
        console.log(re1);

        console.log("getting supported tokens");
		var result1 = await nwt.getSupportedTokens();
		console.log(result1);

		var result = await roa.balanceOf(nwt.address);
		console.log("ROA balance: " + result.toNumber());

		var result3 = await roa.balanceOf(web3.eth.accounts[1]);
		console.log("ROA balance of test account: " + result3.toNumber());	

		var result = await nwt.balanceOf(web3.eth.accounts[1]);
		console.log("Nash on test account: " + web3.fromWei(result).toNumber());		

		console.log("join presale");
		var result2 = await nwt.joinPreSale(roa.address, 100, {from: web3.eth.accounts[1]});	
		//console.log(result2);
		result2.logs.map(l => console.log(l.args));

		var result3 = await roa.balanceOf(web3.eth.accounts[1]);
		console.log("ROA balance of test account: " + result3.toNumber());	

		var result4 = await nwt.balanceOf(web3.eth.accounts[1]);
		console.log("Nash on test account: " + web3.fromWei(result4).toNumber());

		await expectThrow(function() {
			console.log("test balance not enough");
			return nwt.joinPreSale(roa.address, 10000, {from: web3.eth.accounts[1]});	
		});
		await expectThrow(function() {
			console.log("test invalid address");
			return nwt.joinPreSale(web3.eth.accounts[1], 1000, {from: web3.eth.accounts[1]});	
		});
	});

	var account = web3.eth.accounts[2];
	var balance = web3.toWei(3000000);
	var lockTotal = web3.toWei(1000000);
	var starttime = Math.floor(Date.now() / 1000) - 10;
	var period = 10;
	var cycle = 5;

	it ('send init nash', async() => {
		console.log("transfer init balance ");
		var r = await web3Abi.encodeFunctionCall(
            overloadedTransferAbi,
            [
                account,
                balance,
            ]
        );
		let re1 =  web3.eth.sendTransaction({from: web3.eth.accounts[0], to: nwt.address, data: r});
        console.log(re1);		
	})

	// it ('lock test odd numbers', async() => {

	// 	var result = await nwt.balanceOf(account);
	// 	console.log("Nash on test account: " + web3.fromWei(result).toNumber());        

	// 	console.log("trying to lock");


	// 	var result1 = await nwt.lock(
	// 		lockTotal,
	// 		starttime,
	// 		period,
	// 		cycle + 2,
	// 		{from: account}
	// 	);

	// 	console.log("trying to unlock first time");

	// 	await nwt.tryUnlock(
	// 		{from: account}
	// 	);			

	// 	var result1 = await nwt.getLockStatus(account);
	// 	console.log(result1);
	// });

	it ('lock', async() => {


		var result = await nwt.balanceOf(account);
		console.log("Nash on test account: " + web3.fromWei(result).toNumber());        

		console.log("trying to lock");


		var result1 = await nwt.lock(
			lockTotal,
			starttime,
			period,
			cycle,
			{from: account}
		);

		console.log(result1);

		var result = await nwt.balanceOf(account);
		console.log("Nash on test account: " + web3.fromWei(result).toNumber());   	

		assert.equal(result, balance - lockTotal);

		var result1 = await nwt.getLockStatus(account);
		console.log(result1);

		console.log(result1[0]);

		assert.equal(result1[0].toNumber(), lockTotal);
		assert.equal(result1[1].toNumber(), starttime);
		assert.equal(result1[2], period);
		assert.equal(result1[3], cycle);
		assert.equal(result1[4].toNumber(), lockTotal);

    });

	function sleep(ms) {
	  return new Promise(resolve => setTimeout(resolve, ms));
	}

	it ('try to unlock', async() => {
		console.log("unlock 1");

		var result = await nwt.tryUnlock(
			{from: account}
		);		

		console.log(result);

		var result1 = await nwt.getLockStatus(account);
		console.log(result1);

		assert.equal(result1[0].toNumber(), lockTotal);
		assert.equal(result1[1], starttime);
		assert.equal(result1[2], period);
		assert.equal(result1[3], cycle);
		assert.equal(result1[4].toNumber(), lockTotal / cycle * (cycle - 1));
		assert.equal(result1[5].toNumber(), 1);

		var result = await nwt.balanceOf(account);
		console.log("Nash on test account: " + web3.fromWei(result).toNumber());   	

		assert.equal(result, balance - lockTotal * (cycle - 1) / cycle);

		console.log("unlock 2");
		await sleep(period * 1000);

		var result = await nwt.tryUnlock(
			{from: account}
		);		

		console.log(result);

		var result1 = await nwt.getLockStatus(account);
		console.log(result1);

		console.log(result1[0]);

		assert.equal(result1[0].toNumber(), lockTotal);
		assert.equal(result1[1], starttime);
		assert.equal(result1[2], period);
		assert.equal(result1[3], cycle);
		assert.equal(result1[4].toNumber(), lockTotal * (cycle - 2) / cycle );
		assert.equal(result1[5].toNumber(), 2);

		var result = await nwt.balanceOf(account);
		console.log("Nash on test account: " + web3.fromWei(result).toNumber());   	

		assert.equal(result, balance - lockTotal * (cycle - 2) / cycle);		

		await sleep(period * 2 * 1000);

		console.log("unlock 3-4");
		var result = await nwt.tryUnlock(
			{from: account}
		);		

		console.log(result);

		var result1 = await nwt.getLockStatus(account);
		console.log(result1);

		console.log(result1[0]);

		assert.equal(result1[0].toNumber(), lockTotal);
		assert.equal(result1[1], starttime);
		assert.equal(result1[2], period);
		assert.equal(result1[3], cycle);
		assert.equal(result1[4].toNumber(), lockTotal * (cycle - 4) / cycle );
		assert.equal(result1[5].toNumber(), 4);

		var result = await nwt.balanceOf(account);
		console.log("Nash on test account: " + web3.fromWei(result).toNumber());   	

		assert.equal(result, balance - lockTotal * (cycle - 4) / cycle);			

		await sleep(period * 3 * 1000);

		console.log("unlock all");

		var result = await nwt.tryUnlock(
			{from: account}
		);		

		console.log(result);

		var result1 = await nwt.getLockStatus(account);
		console.log(result1);

		console.log(result1[0]);

		assert.equal(result1[0].toNumber(), 0);
		assert.equal(result1[1], 0);
		assert.equal(result1[2], 0);
		assert.equal(result1[3], 0);
		assert.equal(result1[4].toNumber(), 0);
		assert.equal(result1[5].toNumber(), 0);		

		var result = await nwt.balanceOf(account);
		console.log("Nash on test account: " + web3.fromWei(result).toNumber());   	
		console.log(result.toNumber());
		console.log(balance);
		assert.equal(result.toNumber(), balance);			
	});


});