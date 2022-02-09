const iam = artifacts.require("IAM");

module.exports = function (_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(iam);
};
