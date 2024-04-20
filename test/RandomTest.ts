import { expect } from "chai";
import { ethers } from "hardhat";
// import { BN, exectEvent, expectRevert } from '@openzeppelin/test-helpers';

describe("ColourWork", function () {
  let deployer;
  let randomAccount;
  let royaltiesRecipient;

  // const ADDRESS_ZERO = ethers.constants.AddressZero;

  before(async function () {
    this.Random = await ethers.getContractFactory("TestRandom");
  });

  beforeEach(async function () {
    this.random = await this.Random.deploy();
    [deployer, randomAccount, royaltiesRecipient] = await ethers.getSigners();
  });

  // it("test", async function () {
  //   const rand = await this.random.randomInt(318390, 3, 5);
  //   expect(rand).to.equal(5);
  // });

  it("test", async function () {
    const rand = await this.random.randomInt(4632057, 0, 360);
    expect(rand).to.equal(297);
  });

  it("test", async function () {
    const rand = await this.random.randomInt(564706, 0, 255);
    expect(rand).to.equal(216);
  });
});
