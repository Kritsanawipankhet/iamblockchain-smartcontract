const iam = artifacts.require("IAM");
const base64 = artifacts.require("./libraries/Base64");
const string = artifacts.require("./libraries/Strings");

module.exports = async function (_deployer) {
  // Use deployer to state migration tasks.
  await _deployer.deploy(string);
  await _deployer.link(string, iam);
  await _deployer.deploy(base64);
  await _deployer.link(base64, iam);
  await _deployer.deploy(iam);
};
