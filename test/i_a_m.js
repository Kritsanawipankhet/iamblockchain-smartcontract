const IAM = artifacts.require("IAM");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("IAM", function (/* accounts */) {
  it("should assert true", async function () {
    await IAM.deployed();
    return assert.isTrue(true);
  });
});
