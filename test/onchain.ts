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
    berallyPasses = BerallyPasses.attach(process.env.TESTING_BERALLY_PASSES_ADDRESS!) as unknown as BerallyPasses;

    const ownerAddress = await berallyPasses.owner()
    console.log(ownerAddress)
  })

  describe("Actions", function () {
    it("Updating", async function () {
      const z = await berallyPasses.protocolFeePercentage()
      console.log(z)
    })
  })
});
