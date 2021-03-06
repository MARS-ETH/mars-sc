// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarsToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract MarsICO is Ownable, ERC721Holder {
    MarsToken public marsToken;

    uint256 public price;

    constructor(address _marsTokenAddress, uint256 _price) {
        changeMarsTokenAddress(_marsTokenAddress);
        changePrice(_price);
    }

    function changeMarsTokenAddress(address _marsTokenAddress) public onlyOwner {
        require(_marsTokenAddress != address(0), "MarsICO: mars token address must be valid");
        marsToken = MarsToken(_marsTokenAddress);
        require(marsToken.supportsInterface(0x80ac58cd), "MarsICO: mars token must be ERC721");
    }

    function changePrice(uint256 _price) public onlyOwner {
        require(_price > 0, "MarsICO: price must be greather than 0");
        price = _price;
    }

    function buy() external payable {
        require(msg.value >= price, "MarsICO: no enouth ETH");
        marsToken.mint(msg.sender);

        // TODO refund rest
    }
}
