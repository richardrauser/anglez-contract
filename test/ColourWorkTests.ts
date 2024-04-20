import { expect } from "chai";
import { ethers } from "hardhat";
// import { BN, exectEvent, expectRevert } from '@openzeppelin/test-helpers';

describe("ColourWork", function () {
  let deployer;
  let randomAccount;
  let royaltiesRecipient;

  // const ADDRESS_ZERO = ethers.constants.AddressZero;

  before(async function () {
    this.ColourWork = await ethers.getContractFactory("TestColourWork");
  });

  beforeEach(async function () {
    this.colourWork = await this.ColourWork.deploy();
    [deployer, randomAccount, royaltiesRecipient] = await ethers.getSigners();
  });

  it("test safeTint basic", async function () {
    const returnValue1 = await this.colourWork._safeTint(100, 200, 127);
    expect(returnValue1).to.equal(149);

    const returnValue2 = await this.colourWork._safeTint(200, 100, 127);
    expect(returnValue2).to.equal(151);

    const returnValue3 = await this.colourWork._safeTint(100, 100, 127);
    expect(returnValue3).to.equal(100);
  });

  it("test safeTint small tint", async function () {
    const returnValue1 = await this.colourWork._safeTint(255, 2, 127);
    expect(returnValue1).to.equal(129);

    const returnValue2 = await this.colourWork._safeTint(200, 9, 127);
    expect(returnValue2).to.equal(105);

    const returnValue3 = await this.colourWork._safeTint(225, 6, 127);
    expect(returnValue3).to.equal(116);
  });

  it("test extremes", async function () {
    const returnValue1 = await this.colourWork._safeTint(0, 0, 100);
    expect(returnValue1).to.equal(0);

    const returnValue2 = await this.colourWork._safeTint(0, 0, 0);
    expect(returnValue2).to.equal(0);

    const returnValue3 = await this.colourWork._safeTint(255, 255, 110);
    expect(returnValue3).to.equal(255);

    const returnValue4 = await this.colourWork._safeTint(255, 255, 255);
    expect(returnValue4).to.equal(255);
  });

  it("test random set", async function () {
    const returnValue1 = await this.colourWork._safeTint(58, 192, 201);
    expect(returnValue1).to.equal(163);

    const returnValue2 = await this.colourWork._safeTint(63, 73, 44);
    expect(returnValue2).to.equal(64);

    const returnValue3 = await this.colourWork._safeTint(206, 12, 49);
    expect(returnValue3).to.equal(169);

    const returnValue4 = await this.colourWork._safeTint(212, 240, 173);
    expect(returnValue4).to.equal(230);
  });

  it("test rgbString uints", async function () {
    const returnValue1 = await this.colourWork._rgbString(1, 2, 3);
    expect(returnValue1).to.equal("rgb(1, 2, 3)");

    const returnValue2 = await this.colourWork._rgbString(45, 123, 250);
    expect(returnValue2).to.equal("rgb(45, 123, 250)");
  });
});
