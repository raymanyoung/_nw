// var CAL = artifacts.require("./CopyrightedAssetLibrary.sol");
// var CALT = artifacts.require("./CopyrightedAssetLibraryToken.sol");
var NWT = artifacts.require("./NeoWorldToken.sol");
var ROA = artifacts.require("./roa.sol");
var ROB = artifacts.require("./rob.sol");

module.exports = function(deployer) {
  // deployer.deploy(CAL);
  // deployer.deploy(CALT);
  deployer.deploy(NWT);
  deployer.deploy(ROA);
  deployer.deploy(ROB);
  //deployer.deploy(Etheroll);
};