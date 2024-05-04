import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

// We define a fixture to reuse the same setup in every test.
// We use loadFixture to run this setup once, snapshot that state,
// and reset Hardhat Network to that snapshot in every test.
async function deployArtBuilderFixture() {
  // Contracts are deployed using the first signer/account by default
  const [owner, otherAccount] = await ethers.getSigners();

  const Contract = await ethers.getContractFactory("TestArtBuilder");
  const contract = await Contract.deploy();

  return { contract, owner, otherAccount };
}

describe("Traits", function () {
  it("Should display correct Traits", async function () {
    const { contract } = await loadFixture(deployArtBuilderFixture);

    const tokenParams = {
      randomSeed: 1234,
      zoom: 140,
      tint: {
        red: 100,
        green: 101,
        blue: 102,
        alpha: 50,
      },
      shapeCount: 4,
      cyclic: false,
      chaotic: true,
      custom: true,
    };

    const traits = await contract._getTraits(tokenParams);

    const traitsJson = JSON.parse("{" + traits + "}");

    console.log("TRAITS JSON: " + traitsJson);

    const seed = traitsJson.attributes.filter(
      (attribute) => attribute.trait_type == "seed"
    )[0]?.value;

    const zoom = traitsJson.attributes.filter(
      (attribute) => attribute.trait_type == "zoom"
    )[0]?.value;

    const tintColor = traitsJson.attributes.filter(
      (attribute) => attribute.trait_type == "tint color"
    )[0].value;

    const tintAlpha = traitsJson.attributes.filter(
      (attribute) => attribute.trait_type == "tint transparency"
    )[0]?.value;

    const custom = traitsJson.attributes.filter(
      (attribute) => attribute.trait_type == "custom"
    )[0]?.value;

    const style = traitsJson.attributes.filter(
      (attribute) => attribute.trait_type == "style"
    )[0]?.value;

    const structure = traitsJson.attributes.filter(
      (attribute) => attribute.trait_type == "structure"
    )[0]?.value;

    expect(seed).to.equal("1234");
    expect(zoom).to.equal("140 %");
    expect(tintColor).to.equal("rgb(100, 101, 102)");
    expect(tintAlpha).to.equal("19 %");
    expect(style).to.equal("linear");
    expect(structure).to.equal("chaotic");
    expect(custom).to.equal("true");
  });

  it("Should set the right owner", async function () {
    // const { contract, owner } = await loadFixture(deployArtBuilderFixture);
    // expect(await contract.owner()).to.equal(owner.address);
  });
});
