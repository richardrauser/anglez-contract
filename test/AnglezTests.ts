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

      const mintResult = await contract.mintRandom(3479128);
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
        90,
        false,
        false,
        { value: ethers.parseEther("0.01") }
      );
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;
    });

    it("Should not mint random past TOKEN_LIMIT", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      for (let i = 0; i < 512; i++) {
        await contract.mintRandom(i);
      }
      await expect(contract.mintRandom(3479128)).to.be.revertedWith(
        "TOKEN_LIMIT_REACHED"
      );
    });

    it("Should not mint custom past TOKEN_LIMIT", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      for (let i = 0; i < 512; i++) {
        await contract.mintCustom(i, 4, 100, 100, 100, 90, false, false, {
          value: ethers.parseEther("0.01"),
        });
      }
      await expect(
        contract.mintCustom(4566, 4, 100, 100, 100, 90, false, false, {
          value: ethers.parseEther("0.01"),
        })
      ).to.be.revertedWith("TOKEN_LIMIT_REACHED");
    });

    it("Should not mint random + custom past TOKEN_LIMIT", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      for (let i = 0; i < 256; i++) {
        await contract.mintRandom(i);
      }
      for (let i = 256; i < 512; i++) {
        await contract.mintCustom(i, 4, 100, 100, 100, 90, false, false, {
          value: ethers.parseEther("0.01"),
        });
      }

      await expect(contract.mintRandom(3479128)).to.be.revertedWith(
        "TOKEN_LIMIT_REACHED"
      );
    });

    it("Should validate custom params", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.validateCustomParams(
        124,
        4,
        100,
        100,
        100,
        90
      );

      expect(mintResult).to.equal(true);

      await expect(
        contract.validateCustomParams(123456, 1, 100, 100, 100, 90)
      ).to.be.revertedWith("INVALID_SHAPE_COUNT");

      await expect(
        contract.validateCustomParams(1, 21, 100, 100, 100, 90)
      ).to.be.revertedWith("INVALID_SHAPE_COUNT");

      // await expect(
      //   contract.validateCustomParams(1, 21, 256, 100, 100, 90)
      // ).to.be.revertedWith("INVALID_SHAPE_COUNT");

      await expect(
        contract.validateCustomParams(124, 21, 255, 100, 100, 91)
      ).to.be.revertedWith("INVALID_SHAPE_COUNT");
    });

    it("Should not mint custom with underpayment", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      await expect(
        contract.mintCustom(1, 4, 100, 100, 100, 90, false, false, {
          value: ethers.parseEther("0.009"),
        })
      ).to.be.revertedWith("INSUFFICIENT_PAYMENT");
    });

    it("Should not random same seed twice", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      await contract.mintRandom(3479128);
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;

      await expect(contract.mintRandom(3479128)).to.be.revertedWith(
        "SEED_USED"
      );
    });

    it("Should not mint custom same seed twice", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.mintCustom(
        1,
        4,
        100,
        100,
        100,
        90,
        false,
        false,
        { value: ethers.parseEther("0.01") }
      );
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;

      await expect(
        contract.mintCustom(1, 4, 100, 100, 100, 90, false, false, {
          value: ethers.parseEther("0.01"),
        })
      ).to.be.revertedWith("SEED_USED");
    });

    it("Should not mint custom + random same seed twice", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.mintCustom(
        1234,
        4,
        100,
        100,
        100,
        90,
        false,
        false,
        { value: ethers.parseEther("0.01") }
      );
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;

      await expect(contract.mintRandom(1234)).to.be.revertedWith("SEED_USED");
    });

    it("Should not mint random + custom same seed twice", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      await contract.mintRandom(5678);
      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;

      await expect(
        contract.mintCustom(5678, 4, 100, 100, 100, 90, false, false, {
          value: ethers.parseEther("0.01"),
        })
      ).to.be.revertedWith("SEED_USED");
    });

    it("isMinted returns correctly", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);

      const mintResult = await contract.mintCustom(
        1,
        4,
        100,
        100,
        100,
        90,
        false,
        false,
        { value: ethers.parseEther("0.01") }
      );
      const isMinted1 = await contract.isSeedMinted(1);
      const isMinted2 = await contract.isSeedMinted(2);

      expect(isMinted1).to.equal(true);
      expect(isMinted2).to.equal(false);
    });

    it("Should not mint random same seed twice", async function () {
      const { contract } = await loadFixture(deployAnglezFixture);
      const mintResult = await contract.mintCustom(
        1,
        4,
        100,
        100,
        100,
        90,
        false,
        false,
        { value: ethers.parseEther("0.01") }
      );
      const tokenUri = await contract.tokenURI(0);
      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;
      await expect(
        contract.mintCustom(1, 4, 100, 100, 100, 100, false, false, {
          value: ethers.parseEther("0.01"),
        })
      ).to.be.revertedWith("SEED_USED");
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

      await contract.mintCustom(
        0,
        4,
        100,
        100,
        100,
        90,
        false,
        false,
        overrides
      );

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
        90,
        false,
        false,
        overrides
      );

      const tokenUri = await contract.tokenURI(0);

      console.log(tokenUri);
      expect(tokenUri).to.not.be.empty;
      console.log("DONE TEST");
    });
  });

  describe("ERC-2981 Royalties", function () {
    it("Should build anglez", async function () {
      const { contract, owner } = await loadFixture(deployAnglezFixture);

      const info = await contract.royaltyInfo(0, 100);

      // console.log("Royalty Info: ", JSON.stringify(royaltyInfo));

      // expect(info[0]).to.equal(owner.address);
      expect(info[1]).to.equal(10);
      console.log("DONE!!!");
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
