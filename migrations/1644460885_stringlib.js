const stringLib = artifacts.require("./libraries/String");

module.exports = function (_deployer) {
  _deployer.deploy(stringLib);
  // Use deployer to state migration tasks.
};
