// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarsToken is Ownable, ERC721Enumerable {

    uint256 public constant SALE_START_TIMESTAMP = 1615001083; // TODO change

    uint256 public constant MAX_NFT_SUPPLY = 843;

    string public baseTokenURI;

    constructor(string memory name, string memory symbol, string memory _baseTokenURI) ERC721(name, symbol) {      
        changeBaseURI(_baseTokenURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function changeBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getPrice() public view returns (uint256) {
        require(block.timestamp >= SALE_START_TIMESTAMP, "MarsToken: sale has not started");
        require(totalSupply() < MAX_NFT_SUPPLY, "MarsToken: sale has already ended");

        uint currentSupply = totalSupply();

        if (currentSupply >= 841) {
            return 100000000000000000000; // 841 - 843 100 ETH
        } else if (currentSupply >= 800) {
            return 3000000000000000000;   // 800 - 840 3.0 ETH
        } else if (currentSupply >= 700) {
            return 1700000000000000000;   // 700 - 799 1.7 ETH
        } else if (currentSupply >= 600) {
            return 900000000000000000;    // 600 - 699 0.9 ETH
        } else if (currentSupply >= 400) {
            return 500000000000000000;    // 400 - 599 0.5 ETH
        } else if (currentSupply >= 200) {
            return 300000000000000000;    // 200 - 399 0.3 ETH
        } else {
            return 100000000000000000;    //   0 - 199 0.1 ETH 
        }
    }

    function mint() external payable {
        require(block.timestamp >= SALE_START_TIMESTAMP, "MarsToken: sale has not started");
        require(totalSupply() < MAX_NFT_SUPPLY, "MarsToken: sale has already ended");
        require(getPrice() >= msg.value , "MarsToken: no enought Ether");

        _safeMint(_msgSender(), totalSupply(), "");
    
        uint256 refund = msg.value - getPrice();
        payable(msg.sender).transfer(refund);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
