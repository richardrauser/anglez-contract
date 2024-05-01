import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("anglez tests", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAnglezFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("Anglez");
    const contract = await Contract.deploy();

    return { contract, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should deploy", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);
    });

    it("Should set the right owner", async function () {
      const { contract, owner } = await loadFixture(deployAnglezFixture);

      expect(await contract.owner()).to.equal(owner.address);
    });
  });

  describe("Minting", function () {
    it("Should mint random", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.mintRandom(0);
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;
      // expect(await lock.unlockTime()).to.equal(unlockTime);
    });

    it("Should mint custom", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.mintCustom(
        1,
        4,
        100,
        100,
        100,
        100,
        90,
        false,
        { value: ethers.parseEther("0.01") }
      );
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;
    });

    it("Should not mint custom with underpayment", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      await expect(
        contract.mintCustom(1, 4, 100, 100, 100, 100, 90, false, {
          value: ethers.parseEther("0.009"),
        })
      ).to.be.revertedWith("Insufficient payment");
    });

    it("Should not mint custom same seed twice", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.mintCustom(
        1,
        4,
        100,
        100,
        100,
        100,
        90,
        false,
        { value: ethers.parseEther("0.01") }
      );
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;

      await expect(
        contract.mintCustom(1, 4, 100, 100, 100, 100, 90, false, {
          value: ethers.parseEther("0.01"),
        })
      ).to.be.revertedWith("Seed already used");
    });

    it("Should not mint random same seed twice", async function () {
      // TODO
      // const { contract } = await loadFixture(deployAnglezFixture);
      // const mintResult = await contract.mintCustom(
      //   1,
      //   4,
      //   100,
      //   100,
      //   100,
      //   100,
      //   90,
      //   false,
      //   { value: ethers.parseEther("0.01") }
      // );
      // const tokenUri = await contract.tokenURI(0);
      // console.log(tokenUri);
      // expect(tokenUri).to.not.be.empty;
      // await expect(
      //   contract.mintCustom(1, 4, 100, 100, 100, 100, 90, false, {
      //     value: ethers.parseEther("0.01"),
      //   })
      // ).to.be.revertedWith("Seed already used");
    });

    it("Should set random mint price", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.setRandomMintPrice(
        ethers.parseEther("0.1")
      );
      const mintPrice = await contract.getRandomMintPrice();

      expect(mintPrice).to.equal(ethers.parseEther("0.1"));
    });

    it("Should set custom mint price", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.setCustomMintPrice(
        ethers.parseEther("0.2")
      );
      const mintPrice = await contract.getCustomMintPrice();

      expect(mintPrice).to.equal(ethers.parseEther("0.2"));
    });
  });

  describe("Withdrawals", function () {
    it("Should transfer the funds to the owner", async function () {
      const { contract, owner } = await loadFixture(deployAnglezFixture);

      const amount = ethers.parseEther("0.01");
      const overrides = { value: amount };

      await contract.mintCustom(0, 4, 100, 100, 100, 100, 90, false, overrides);

      await expect(contract.withdraw()).to.changeEtherBalances(
        [owner, contract],
        [amount, ethers.parseEther("-0.01")]
      );
    });
  });

  describe("Experiment", function () {
    it("Should build anglez", async function () {
      const { contract, owner } = await loadFixture(deployAnglezFixture);

      const amount = ethers.parseEther("0.01");
      const overrides = { value: amount };

      await contract.mintCustom(
        2517930,
        4,
        100,
        100,
        100,
        100,
        90,
        false,
        overrides
      );

      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;
      console.log("DONE TEST");
    });
  });

  describe("Events", function () {
    //   it("Should emit an event on withdrawals", async function () {
    //     const { lock, unlockTime, lockedAmount } = await loadFixture(
    //       deployOneYearLockFixture
    //     );
    //     await time.increaseTo(unlockTime);
    //     await expect(lock.withdraw())
    //       .to.emit(lock, "Withdrawal")
    //       .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
    //   });
    // });
    // describe("Transfers", function () {
    //   it("Should transfer the funds to the owner", async function () {
    //     const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
    //       deployOneYearLockFixture
    //     );
    //     await time.increaseTo(unlockTime);
    //     await expect(lock.withdraw()).to.changeEtherBalances(
    //       [owner, lock],
    //       [lockedAmount, -lockedAmount]
    //     );
    //   });
    // });
  });
});
