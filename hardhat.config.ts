import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 400,
      },
      viaIR: true,
    },
  },
  // sourcify: {
  //   enabled: true,
  // },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    baseSepolia: {
      url: `${process.env.COINBASE_BASE_SEPOLIA_URL}`,
      accounts: [`0x${process.env.WALLET_PRIVATE_KEY}`],
    },
    sepolia: {
      url: `${process.env.ALCHEMY_SEPOLIA_URL}`,
      accounts: [`0x${process.env.WALLET_PRIVATE_KEY}`],
    },
    // rinkeby: {
    //   url: `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
    //   accounts: [`0x${process.env.RINKEBY_PRIVATE_KEY}`, ``],
    // },
    // mainnet: {
    //   url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
    //   accounts: [`0x${process.env.MAINNET_PRIVATE_KEY}`],
    // },
    //   mumbai: {
    //     url: "https://rpc-mumbai.maticvigil.com",
    //     accounts: [`0x${process.env.MUMBAI_PRIVATE_KEY}`],
    //     gasPrice: 8000000000, // default is 'auto' which breaks chains without the london hardfork
    //   },
    //   mainnet: {
    //     url: "https://polygon-mainnet.g.alchemy.com/v2/a0lCrlRVU2AlAdAclC0DfCvJ6FLIKQ3V",
    //     accounts: [`0x${process.env.POLYGON_MAINNET_PRIVATE_KEY}`],
    //     // gasPrice: 8000000000, // default is 'auto' which breaks chains without the london hardfork
    //   },
  },
  etherscan: {
    apiKey: {
      sepolia: "U68IY6DYDAPQ99Z34E3HYG9K4F97I1ETK7",
      // polygon: process.env.POLYGONSCAN_API_KEY,
      // polygonMumbai: process.env.POLYGONSCAN_API_KEY,
    },
  },
};

export default config;
