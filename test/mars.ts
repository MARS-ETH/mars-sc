import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer, BigNumber } from "ethers";
import { expect } from "chai";

describe("Mars Project", function () {
    let accounts: Signer[];
    let owner: Signer;
    let user: Signer;

    let MarsToken: ContractFactory;
    let MarsICO: ContractFactory;

    const NumberOfTokens = 843;
    const TokenPrice = ethers.utils.parseUnits('0.1', 'ether');

    before(async () => {
        accounts = await ethers.getSigners();
        [owner, user] = accounts;

        MarsToken = await ethers.getContractFactory("MarsToken");
        MarsICO = await ethers.getContractFactory("MarsICO");
    });

    let marsToken: Contract;
    let marsICO: Contract;

    it("Should deploy Mars NFT token", async () => {
        marsToken = await MarsToken.deploy("Mars Land", "MARS", "", NumberOfTokens);
        await marsToken.deployed();
        expect(await marsToken.owner()).to.equal(await owner.getAddress());
        expect(await marsToken.baseURI()).to.equal("");
    });

    it("Should not change baseURI if not owner", async () => {
        const evilBaseURI = "http://evilhost/";
        expect(marsToken.connect(user).changeBaseURI(evilBaseURI)).to.be.reverted;
        expect(await marsToken.baseURI()).to.not.equal(evilBaseURI);
    });

    it("Should not mint if not minter", async () => {
        expect(marsToken.connect(user).mint()).to.be.reverted;
    });

    it("Should not deploy Mars ICO with invalid addresses", async () => {
        expect(MarsICO.deploy("0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000")).to.be.reverted;
        expect(MarsICO.deploy("0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE", "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE")).to.be.reverted;
        expect(MarsICO.deploy("0x0000000000000000000000000000000000000000", "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE")).to.be.reverted;
        expect(MarsICO.deploy("0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE", "0x0000000000000000000000000000000000000000")).to.be.reverted;
    });

    it("Should deploy Mars ICO", async () => {
        marsICO = await MarsICO.deploy(marsToken.address, TokenPrice);
        expect(await marsICO.owner()).to.equal(await owner.getAddress());
        expect(await marsICO.price()).to.equal(TokenPrice);
    });

    it("Should not buy token if ICO is not minter", async () => {
        expect(marsICO.connect(user).buy(0)).to.be.reverted;
    });

    it("Should set ICO as minter", async () => {
        expect(marsToken.connect(user).grantRole(await marsToken.MINTER_ROLE(), marsICO.address)).to.be.reverted;
        expect(await marsToken.grantRole(await marsToken.MINTER_ROLE(), marsICO.address));
    });

    it("Should not buy token if no ETH", async () => {
        expect(marsICO.connect(user).buy()).to.be.reverted;
        expect(marsICO.connect(user).buy({ value: TokenPrice.sub('1') })).to.be.reverted;
    });

    it("Should buy token with ETH", async () => {
        expect(await marsICO.connect(user).buy({ value: TokenPrice }));
    });
});