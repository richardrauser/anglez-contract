// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "erc721a/contracts/ERC721A.sol";
import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./ArtBuilder.sol";
import "./TokenParams.sol";
import "./Random.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Anglez is ERC721AQueryable, ERC2981, Ownable {
    uint16 public constant TOKEN_LIMIT = 512;
    // uint public unlockTime;
    // address payable public owner;
    uint256 private randomMintPrice = 0 ether;
    uint256 private customMintPrice = 0.01 ether;
    //tokensarray
    mapping(uint256 => TokenParams) private tokenParamsMapping;
    mapping(uint24 => bool) private usedRandomSeeds;

    constructor() ERC721A("Anglez", "AGLZ") Ownable(msg.sender) {
            // require(
        //     block.timestamp < _unlockTime,
        //     "Unlock time should be in the future"
        // );

        // unlockTime = _unlockTime;
        // owner = payable(msg.sender);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721A, IERC721A, ERC2981)
        returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // function withdraw() public {
    //     // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
    //     // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

    //     require(block.timestamp >= unlockTime, "You can't withdraw yet");
    //     require(msg.sender == owner, "You aren't the owner");

    //     emit Withdrawal(address(this).balance, block.timestamp);

    //     owner.transfer(address(this).balance);
    // }

        // Payments
    function withdraw() public onlyOwner {
        address payable owner = payable(owner());        
        owner.transfer(address(this).balance);
    }

    // For OpenSea

    function contractURI() public pure returns (string memory) {
        return "https://mint.beyondhuman.ai/storefront-metadata";
    }

    // Minting

    function getRandomMintPrice() public view returns (uint256) {
        return randomMintPrice;
    }

    function setRandomMintPrice(uint256 _randomMintPrice) public onlyOwner {
        randomMintPrice = _randomMintPrice;
    }

    function getCustomMintPrice() public view returns (uint256) {
        return customMintPrice;
    }

    function setCustomMintPrice(uint256 _customMintPrice) public onlyOwner {
        customMintPrice = _customMintPrice;
    }

    function mintRandom(uint24 seed) public payable {
        // TODO: Error messages
        require(msg.value >= randomMintPrice, "Insufficient payment");
        require(!usedRandomSeeds[seed], "Seed already used");

        // TODO: support multi random mints via array of seeds?
        console.log("Minting with seed: ");
        console.log(seed);
        
        uint8 shapeCount = Random.randomInt8(seed + 5, 5, 8);

        uint8 red = Random.randomInt8(seed + 6, 0, 255);
        uint8 green = Random.randomInt8(seed + 7, 0, 255);
        uint8 blue = Random.randomInt8(seed + 8, 0, 255);
        uint alpha =  Random.randomInt (seed + 9, 10, 90) * 255 / 100;
        uint8 alpha8 = uint8(alpha);
        bool isCyclic = Random.randomInt(seed + 4, 0, 1) == 1;
        bool isChaotic = Random.randomInt(seed + 11, 0, 1) == 1;

        Tint memory tint = Tint({
            red: red,
            green: green,
            blue: blue,
            alpha: alpha8
        });

        TokenParams memory tokenParams = TokenParams({
            randomSeed: seed,
            tint: tint,
            shapeCount: shapeCount,
            cyclic: isCyclic,
            custom: false,
            chaotic: isChaotic
        }); 

        uint256 tokenId = _nextTokenId();
        _mint(msg.sender, 1);
        tokenParamsMapping[tokenId] = tokenParams;
        usedRandomSeeds[seed] = true;
    }

    function validateCustomParams(uint24 seed, uint8 shapeCount, uint8 tintRed, uint8 tintGreen, uint8 tintBlue, uint8 tintAlpha) public view returns (bool) {

        if (usedRandomSeeds[seed]) {
            console.log("Seed already used");
            return false;
        }
        if (shapeCount < 2 || shapeCount > 20) {
            return false;
        }
        if (tintRed < 0 || tintRed > 255) {
            return false;
        }
        if (tintGreen < 0 || tintGreen > 255) {
            return false;
        }
        if (tintBlue < 0 || tintBlue > 255) {
            return false;
        }
        if (tintAlpha < 0 || tintAlpha > 255) {
            return false;
        }

        return true;
    }

    function mintCustom(uint24 seed, uint8 shapeCount, uint8 tintRed, uint8 tintGreen, uint8 tintBlue, uint8 tintAlpha, bool isCyclic, bool isChaotic) public payable {
        require(msg.value >= customMintPrice, "Insufficient payment");
        require(!usedRandomSeeds[seed], "Seed already used");
        require(shapeCount >= 2 && shapeCount <= 20, "Invalid shape count");
        require(tintRed >= 0 && tintRed <= 255, "Invalid red tint");
        require(tintGreen >= 0 && tintGreen <= 255, "Invalid green tint");
        require(tintBlue >= 0 && tintBlue <= 255, "Invalid blue tint");
        require(tintAlpha >= 0 && tintAlpha <= 255, "Invalid alpha tint");

        TokenParams memory tokenParams = TokenParams({
            randomSeed: seed,
            tint: Tint({
                red: tintRed,
                green: tintGreen,
                blue: tintBlue,
                alpha: tintAlpha
            }),
            shapeCount: shapeCount,
            cyclic: isCyclic,
            custom: true,
            chaotic: isChaotic
        }); 

        uint256 tokenId = _nextTokenId();

        _mint(msg.sender, 1);

        tokenParamsMapping[tokenId] = tokenParams;
        usedRandomSeeds[seed] = true;
    }
    
        // Returning minted NFTs

    function isSeedMinted(uint24 seed) public view returns (bool) {
        return usedRandomSeeds[seed];
    }   

    function tokenURI(uint256 _tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(_tokenId), "BAD_ID");
    
        // TODO: Consider if base64 encoding is necessary.. which chain to use?
        // Base64 encode because OpenSea does not interpret data properly as plaintext served from Polygon
        return string(abi.encodePacked(
            'data:application/json,{"name":"AGLZ #',  StringUtils.uintToString(_tokenId), ': beautiful, colorful, abstract anglez",'
                '"description": "Anglez is on-chain, generative NFT art - https://anglez.xyz", ', 
                ArtBuilder.getTraits(tokenParamsMapping[_tokenId]), ', '
                '"image": "data:image/svg+xml,', 
                generateSvg(_tokenId), 
                '"}'
            )); 
    }

    function generateSvg(uint256 _tokenId) public view returns (string memory) {
        require(_exists(_tokenId) && _tokenId < TOKEN_LIMIT, "BAD_ID");
        return ArtBuilder.build(tokenParamsMapping[_tokenId]);
    }    

}
