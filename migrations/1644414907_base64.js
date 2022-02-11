const base64 = artifacts.require("./libraries/Base64");

module.exports = function (_deployer) {
  _deployer.deploy(base64);
  // Use deployer to state migration tasks.
};
