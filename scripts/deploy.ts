import { ethers, upgrades, run, network } from "hardhat";
async function main() {
  const BerallyPasses = await ethers.getContractFactory("BerallyPasses");
  const berallyPasses = await upgrades.deployProxy(BerallyPasses);

  console.log(
    `BerallyPasses deployed to ${await berallyPasses.getAddress()}`
  );

  if(network.name !== "localhost") {
      console.log("Sleeping for 61 seconds...");
      await new Promise((resolve) => setTimeout(resolve, 61000));

    const address = await berallyPasses.getAddress()
    await run("verify:verify", {
      address,
    });
  }
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
