require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-dependency-compiler");

module.exports = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      // gas: 2100000,
      // gasPrice: 880000000,
      // initialBaseFeePerGas: 80000,
    },
  },
  solidity: {
    compilers: [
      { version: "0.8.7" },
      { version: "0.7.6" },
      { version: "0.6.6" },
    ],
  },
  dependencyCompiler: {
    paths: [
      "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol",
      "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol",
    ],
  },
};

// 29910924196216019103
// 29908511231216019103
// 29907728638216019103
// 29906828638216019103
// 29905928638216019103
// 29901428638216019103

// 29900509493416019103