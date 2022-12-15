# EnsOcean Smart Contracts
    
# 1. Install Dependencies
```shell 
$ npm install
```
# 2. Set ENV variables
Rename .env.template to .env and set your variables.

# 3. Run Tests
```shell
$ npx hardhat test
```

Some tests which are like bulkRegister, bulkRenew etc. are not available to test on local chain. It is because of the ENS contract did not deploy to local. To do that run scripts with the network "goerli" You can find deployed contracts in the following lines.

# 4. Run Scripts
```shell
$ npx hardhat run scripts/bulk-test.js --network goerli
```

# 5. Deploy 
```shell
$ npx hardhat run scripts/deploy-bulk-registrar.js --network goerli
```

# 6. Verify
```shell
$ npx hardhat verify --network goerli DEPLOYED_CONTRACT_ADDRESS "argument 1"
```

# 6. Deployed Contracts

## BulkRegister
### Goerli
`0x9A2f24D9874a53e39f5a149Cd086EbECfa5b184a`
### Mainnet
`0x655b9CE192A77C33A782CEF786EeEEB6735e4202`

## ReverseLookup
### Goerli
`0x68D4Bbf0946d0bFaaC5DaF37f2Ded7a021BBF942`
### Mainnet
`0x12Cc189fE58c2722c7621375d82373332ebD6e0f`
