var CAL = artifacts.require("./CopyrightedAssetLibrary.sol");
var CALT = artifacts.require("./CopyrightedAssetLibraryToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CAL);
  deployer.deploy(CALT);
  //deployer.deploy(Etheroll);
};