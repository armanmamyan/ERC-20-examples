require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()


task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.11",
  rinkeby: {
    url: 'https://eth-rinkeby.alchemyapi.io/v2/EuIE_zynWK0cQGApoluXghpYeDusyQvs',
    accounts: [`0x${process.env.PRIVATE_KEY}`]
  }
};
