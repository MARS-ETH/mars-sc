// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarsToken is Ownable, ERC721Enumerable {

    // Time at which the sale will start
    uint256 public constant SALE_START_TIMESTAMP = 1615001083; // TODO change

    // Time after which Mars plot are randomized and allotted
    uint256 public constant REVEAL_TIMESTAMP = SALE_START_TIMESTAMP + (86400 * 14); // TODO change

    // Price to change a Mars plot
    uint256 public constant NAME_CHANGE_PRICE = 1830 * (10 ** 18); // TODO change

    // Number of total Mars plot NFT
    uint256 public constant MAX_NFT_SUPPLY = 843;

    // Block number of starting index
    uint256 public startingIndexBlock;

    // NFT starting index
    uint256 public startingIndex;

    // Base token URI for each NFT
    string public baseTokenURI;

    // Mapping from token ID to name
    mapping (uint256 => string) private _tokenName;

    // Mapping if certain name string has already been reserved
    mapping (string => bool) private _nameReserved;

    // Mapping from token ID to whether the Hashmask was minted before reveal
    mapping (uint256 => bool) private _mintedBeforeReveal;

    // Event emited after each new minted NFT
    event MarsLandMint(uint256 id);

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory _name, string memory _symbol, string memory _baseTokenURI) ERC721(_name, _symbol) {      
        changeBaseURI(_baseTokenURI);
    }

    /**
     * @dev Returns the base URI for each NFT
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @dev Changes the base URI for each NFT
     */
    function changeBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    /**
     * @dev Gets current Mars plot price
     */
    function getPrice() public view returns (uint256) {
        require(block.timestamp >= SALE_START_TIMESTAMP, "MarsToken: sale has not started");
        require(totalSupply() < MAX_NFT_SUPPLY, "MarsToken: sale has already ended");

        uint currentSupply = totalSupply();

        if (currentSupply >= 840) {
            return 100000000000000000000; // 840 - 842 100 ETH
        } else if (currentSupply >= 800) {
            return 3000000000000000000;   // 800 - 839 3.0 ETH
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

    /**
    * @dev Mints Mars plots
    */
    function mint() external payable {
        require(block.timestamp >= SALE_START_TIMESTAMP, "MarsToken: sale has not started");
        require(totalSupply() < MAX_NFT_SUPPLY, "MarsToken: sale has already ended");
        require(msg.value >= getPrice(), "MarsToken: no enought Ether");

        uint256 refund = msg.value - getPrice();
        uint256 currentIndex = totalSupply();

        _safeMint(_msgSender(), currentIndex, "");
        payable(msg.sender).transfer(refund);

        /**
        * Source of randomness. Theoretical miner withhold manipulation possible but should be sufficient in a pragmatic sense
        */
        if (startingIndexBlock == 0 && (totalSupply() == MAX_NFT_SUPPLY || block.timestamp >= REVEAL_TIMESTAMP)) {
            startingIndexBlock = block.number;
        }

        emit MarsLandMint(currentIndex);
    }

    /**
    * @dev Withdraws money
    */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /**
     * @dev Finalize starting index
     */
    function finalizeStartingIndex() public {
        require(startingIndex == 0, "Starting index is already set");
        require(startingIndexBlock != 0, "Starting index block must be set");
        
        startingIndex = uint(blockhash(startingIndexBlock)) % MAX_NFT_SUPPLY;
        // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
        if (block.number - startingIndexBlock > 255) {
            startingIndex = uint(blockhash(block.number-1)) % MAX_NFT_SUPPLY;
        }
        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex = startingIndex + 1;
        }
    }

    /**
     * @dev Returns if the name has been reserved.
     */
    function isNameReserved(string memory nameString) public view returns (bool) {
        return _nameReserved[toLower(nameString)];
    }

     /**
     * @dev Returns if the NFT has been minted before reveal phase
     */
    function isMintedBeforeReveal(uint256 index) public view returns (bool) {
        return _mintedBeforeReveal[index];
    }

    // TODO change name + NCT token

    /**
     * @dev Check if the name string is valid (Alphanumeric and spaces without leading or trailing space)
     */
    function validateName(string memory str) public pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length < 1) return false;
        if(b.length > 25) return false; // Cannot be longer than 25 characters
        if(b[0] == 0x20) return false; // Leading space
        if (b[b.length - 1] == 0x20) return false; // Trailing space

        bytes1 lastChar = b[0];

        for(uint i; i<b.length; i++){
            bytes1 char = b[i];

            if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces

            if(
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) && //a-z
                !(char == 0x20) //space
            )
                return false;

            lastChar = char;
        }

        return true;
    }

    /**
     * @dev Converts the string to lowercase
     */
    function toLower(string memory str) public pure returns (string memory){
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}
