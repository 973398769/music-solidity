const hre = require('hardhat');
const fs = require('fs');

async function main() {
    const MusicNFTMgr = await hre.ethers.getContractFactory('MusicNFTMgr');
    const mintedNFTMgr = await MusicNFTMgr.deploy();
    await mintedNFTMgr.deployed();
    console.log('MusicNFTMgr deployed to:', mintedNFTMgr.address);

    const MusicNFT = await hre.ethers.getContractFactory('MusicNFT');
    const nft = await MusicNFT.deploy(mintedNFTMgr.address);
    await nft.deployed();
    console.log('MusicNft deployed to:', nft.address);

    const config = `export const mintedMusicAddress = '${mintedNFTMgr.address}';\nexport const nftAddress = '${nft.address}';\n`;
    const json = {
        mintedMusicAddress: mintedNFTMgr.address,
        nftAddress: nft.address
    };
    const data = JSON.stringify(config);
    const jsonData = JSON.stringify(json);

    fs.writeFileSync('deployedContracts.js', JSON.parse(data));
    fs.writeFileSync('deployedContracts.json', jsonData);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });