var Migrations = artifacts.require("./Migrations.sol");
// var CAL = artifacts.require("./CopyrightedAssetLibrary.sol");
// var CALT = artifacts.require("./CopyrightedAssetLibraryToken.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  // deployer.deploy(CAL);
  // deployer.deploy(CALT);
};
