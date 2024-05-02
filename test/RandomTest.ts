import { expect } from "chai";
import { ethers } from "hardhat";
// import { BN, exectEvent, expectRevert } from '@openzeppelin/test-helpers';

describe("Random", function () {
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

  it("test randomInt8", async function () {
    const rand = await this.random.randomInt8(564706, 0, 255);
    expect(rand).to.equal(216);
  });

  it("test randomInt8 zoom simulation", async function () {
    const rand = await this.random.randomInt8(3479128 + 3, 50, 100);
    expect(rand).to.equal(80);
  });

  it("test randomInt8 mint with seed 4807620", async function () {
    const zoom = await this.random.randomInt8(4807620 + 3, 50, 100);
    expect(zoom).to.equal(54);

    const shapeCount = await this.random.randomInt8(4807620 + 5, 5, 8);
    expect(shapeCount).to.equal(5);
  });

  it("test randomInt8 with 0 seed ", async function () {
    const seed = 0;

    const zoom = await this.random.randomInt8(seed + 3, 50, 100);
    const shapeCount = await this.random.randomInt8(seed + 5, 5, 8);

    const red = await this.random.randomInt8(seed + 6, 0, 255);
    const green = await this.random.randomInt8(seed + 7, 0, 255);
    const blue = await this.random.randomInt8(seed + 8, 0, 255);
    // const alpha = ((await this.random.randomInt(seed + 9, 10, 90)) * 255) / 100;
    const isCyclic = (await this.random.randomInt(seed + 4, 0, 1)) == 1;
  });
});
