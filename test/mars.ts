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

    /*beforeEach(async () => {
        marsToken = await MarsToken.deploy("Mars Land", "MARS", "");
        await marsToken.deployed();
    });*/

    it("Should deploy Mars NFT token", async () => {
        marsToken = await MarsToken.deploy("Mars Land", "MARS", "");
        await marsToken.deployed();
        expect(await marsToken.owner()).to.equal(await owner.getAddress());
        expect(await marsToken.baseTokenURI()).to.equal("");
    });

    it("Should not change baseURI if not owner", async () => {
        const evilBaseURI = "http://evilhost/";
        await expect(marsToken.connect(user).changeBaseURI(evilBaseURI)).to.be.revertedWith('Ownable: caller is not the owner');
        expect(await marsToken.baseTokenURI()).to.not.equal(evilBaseURI);
    });

    it("Should change baseURI as owner", async () => {
        const goodBaseURI = "http://goodhost/";
        await marsToken.changeBaseURI(goodBaseURI);
        expect(await marsToken.baseTokenURI()).to.equal(goodBaseURI);
    });

    it("Should not buy token if no ETH", async () => {
        await expect(marsToken.connect(user).mint()).to.be.revertedWith('MarsToken: no enought Ether');
        await expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('0.09', 'ether') })).to.be.revertedWith('MarsToken: no enought Ether');
    });

    it("Should buy 0-199 tokens with ETH", async () => {
        const marsTokenAsUser = marsToken.connect(user);
        
        for (let i = 0; i < 200; i++) {
            await expect(await marsTokenAsUser.mint({ value: ethers.utils.parseUnits('0.1', 'ether') })).to.emit(marsToken, 'MarsLandMint').withArgs(i);
        };

        expect(await marsToken.totalSupply()).to.equal(200);

    });

    it.skip("Should buy 200-399 tokens with ETH", async () => {
        const marsTokenAsUser = marsToken.connect(user);
        await expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('0.1', 'ether') })).to.be.revertedWith('MarsToken: no enought Ether');

        for (let i = 200; i < 400; i++) {
            await expect(await marsTokenAsUser.mint({ value: ethers.utils.parseUnits('0.3', 'ether') })).to.emit(marsToken, 'MarsLandMint').withArgs(i);
        };

        expect(await marsToken.totalSupply()).to.equal(400);
    });

    it.skip("Should buy 400-599 tokens with ETH", async () => {
        const marsTokenAsUser = marsToken.connect(user);
        await expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('0.3', 'ether') })).to.be.revertedWith('MarsToken: no enought Ether');

        for (let i = 400; i < 600; i++) {
            await expect(await marsTokenAsUser.mint({ value: ethers.utils.parseUnits('0.5', 'ether') })).to.emit(marsToken, 'MarsLandMint').withArgs(i);
        };

        expect(await marsToken.totalSupply()).to.equal(600);
    });

    it.skip("Should buy 600-699 tokens with ETH", async () => {
        const marsTokenAsUser = marsToken.connect(user);
        await expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('0.5', 'ether') })).to.be.revertedWith('MarsToken: no enought Ether');

        for (let i = 600; i < 700; i++) {
            await expect(await marsTokenAsUser.mint({ value: ethers.utils.parseUnits('0.9', 'ether') })).to.emit(marsToken, 'MarsLandMint').withArgs(i);
        };
        expect(await marsToken.totalSupply()).to.equal(700);
    });

    it.skip("Should buy 700-799 tokens with ETH", async () => {
        const marsTokenAsUser = marsToken.connect(user);
        await expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('0.9', 'ether') })).to.be.revertedWith('MarsToken: no enought Ether');

        for (let i = 700; i < 800; i++) {
            await expect(await marsTokenAsUser.mint({ value: ethers.utils.parseUnits('1.7', 'ether') })).to.emit(marsToken, 'MarsLandMint').withArgs(i);
        };

        expect(await marsToken.totalSupply()).to.equal(800);
    });

    it.skip("Should buy 800-839 tokens with ETH", async () => {
        const marsTokenAsUser = marsToken.connect(user);
        await expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('1.7', 'ether') })).to.be.revertedWith('MarsToken: no enought Ether');

        for (let i = 800; i < 840; i++) {
            await expect(await marsTokenAsUser.mint({ value: ethers.utils.parseUnits('3.0', 'ether') })).to.emit(marsToken, 'MarsLandMint').withArgs(i);
        };

        expect(await marsToken.totalSupply()).to.equal(840);
    });

    it.skip("Should buy 840-842 tokens with ETH", async () => {
        const marsTokenAsUser = marsToken.connect(user);
        await expect(marsToken.connect(user).mint({ value: ethers.utils.parseUnits('3.0', 'ether') })).to.be.revertedWith('MarsToken: no enought Ether');

        for (let i = 840; i < 843; i++) {
            await expect(await marsTokenAsUser.mint({ value: ethers.utils.parseUnits('100.0', 'ether') })).to.emit(marsToken, 'MarsLandMint').withArgs(i);
        };

        expect(await marsToken.totalSupply()).to.equal(843);
        await expect(marsTokenAsUser.mint({ value: ethers.utils.parseUnits('100.0', 'ether') })).to.be.revertedWith('MarsToken: sale has already ended');
    });

    it("Should not allowed to withdraw money as user", async () => {
        await expect(marsToken.connect(user).withdraw()).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("Should withdraw money as onwer", async () => {
        const marsTokenBalance = await ethers.provider.getBalance(marsToken.address);
        await expect(await marsToken.withdraw()).to.changeEtherBalance(owner, marsTokenBalance);
        expect(await ethers.provider.getBalance(marsToken.address)).to.equal(0);
    });
});