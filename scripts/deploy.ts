import { ethers } from "hardhat";

async function main() {
  const contract = await ethers.deployContract("Anglez");

  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log(`Contract deployeed to ${address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
