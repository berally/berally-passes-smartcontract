import { expect } from "chai";
import { ethers } from "hardhat";
import { BerallyPasses } from "../types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("Berally Passes Test: OnChain", function () {
  let owner: HardhatEthersSigner
  let berallyPasses: BerallyPasses

  this.beforeAll(async function () {
    [owner] = await ethers.getSigners();

    const BerallyPasses = await ethers.getContractFactory("BerallyPasses");
    console.log('aa', process.env.TESTING_BERALLY_PASSES_ADDRESS)
    berallyPasses = BerallyPasses.attach(process.env.TESTING_BERALLY_PASSES_ADDRESS!) as unknown as BerallyPasses;

    const ownerAddress = await berallyPasses.owner()
    console.log(ownerAddress)
  })

  describe("Buy & Sell", function () {
    let totalSupply = 0n
    const factor = 24000

    it("Buy the first pass", async function () {
      const price = await berallyPasses.getBuyPriceAfterFee(owner.address, 1)
      expect(price).to.equal(0)

      const tx = await berallyPasses.connect(owner).buyPasses(owner.address, 1, factor)
      totalSupply++

      expect(await berallyPasses.passesSupply(owner.address)).to.equal(totalSupply)
      expect(await berallyPasses.passesBalance(owner.address, owner.address)).to.equal(1)
    })
  })
});
