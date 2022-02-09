# IAMBlockchain Smartcontract

This is a [SmartContract](https://trufflesuite.com/docs/truffle/index.html) project 

## Getting Started

First, run the development server:
```bash
npm install
```
- Setting config in truffle-config.js 
config you local network blockchain if you using ganache
```javascript
networks: {
    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 9545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
    },
```

When you need deploy to mainnet , testnet follow this way:
```bash
touch .secret && echo “(mnemonic code,seed phrase,seed words)” > .secret 
## mnemonic "inmate surprise witness aerobic genius mean excess finger zebra private link goddess"
```
and config network provider as you want, this example for ropsten network 
```javascript
ropsten: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://ropsten.infura.io/v3/YOUR-PROJECT-ID`
        ),
      network_id: 3, // Ropsten's id
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
```
## Deploy
``` bash
truffle compile
truffle migrate --network development # development , ropsten 
```
## Learn More
To learn more about smartcontract, take a look at the following resources:
- [Learn Solidity](https://docs.soliditylang.org/en/v0.8.11/) - learn about solidity language.
- [Truffle Documentation](https://trufflesuite.com/docs/truffle/index.html)learn about Truffle features.
