import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer, BigNumber } from "ethers";
import { expect } from "chai";

describe("Mars Project", function () {
    let accounts: Signer[];
    let owner: Signer;
    let user: Signer;

    let MarsToken: ContractFactory;
    let marsToken: Contract;

    before(async () => {
        accounts = await ethers.getSigners();
        [owner, user] = accounts;

        MarsToken = await ethers.getContractFactory("MarsToken");
    });

    it("Should deploy Mars NFT token", async () => {
        marsToken = await MarsToken.deploy("Mars Land", "MARS", "");
        await marsToken.deployed();
        expect(await marsToken.owner()).to.equal(await owner.getAddress());
        expect(await marsToken.baseTokenURI()).to.equal("");
    });

    it("Should not change baseURI if not owner", async () => {
        const evilBaseURI = "http://evilhost/";
        expect(marsToken.connect(user).changeBaseURI(evilBaseURI)).to.be.reverted;
        expect(await marsToken.baseTokenURI()).to.not.equal(evilBaseURI);
    });

    it("Should change baseURI as owner", async () => {
        const goodBaseURI = "http://goodhost/";
        expect(await marsToken.changeBaseURI(goodBaseURI));
        expect(await marsToken.baseTokenURI()).to.equal(goodBaseURI);
    });

    it("Should not buy token if no ETH", async () => {
        expect(marsToken.connect(user).mint()).to.be.reverted;
        expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('0.09', 'ether') })).to.be.reverted;
    });

    it("Should buy token with ETH", async () => {
        expect(await marsToken.connect(user).mint({ value: ethers.utils.parseUnits('0.1', 'ether') }));
    });
});