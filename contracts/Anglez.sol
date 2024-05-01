// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "erc721a/contracts/ERC721A.sol";
import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./ArtBuilder.sol";
import "./TokenParams.sol";

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

        Tint memory tint = Tint({
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0
        });

        TokenParams memory tokenParams = TokenParams({
            randomSeed: seed,
            zoom: 0,
            tint: tint,
            shapeCount: 0,
            cyclic: false,
            custom: false
        }); 

        uint256 tokenId = _nextTokenId();
        _mint(msg.sender, 1);
        tokenParamsMapping[tokenId] = tokenParams;
        usedRandomSeeds[seed] = true;
    }

    function mintCustom(uint24 seed, uint8 shapeCount, uint8 zoom, uint8 tintRed, uint8 tintGreen, uint8 tintBlue, uint8 tintAlpha, bool isCyclic) public payable {
        require(msg.value >= customMintPrice, "Insufficient payment");
        require(!usedRandomSeeds[seed], "Seed already used");

        TokenParams memory tokenParams = TokenParams({
            randomSeed: seed,
            zoom: zoom,
            tint: Tint({
                red: tintRed,
                green: tintGreen,
                blue: tintBlue,
                alpha: tintAlpha
            }),
            shapeCount: shapeCount,
            cyclic: isCyclic,
            custom: true
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

    // function allMinted() public view returns (bool[] memory) {
    //     bool[] memory minted = new bool[](TOKEN_LIMIT + 1);
    //     minted[0] = false;
    //     for (uint i = 1; i <= TOKEN_LIMIT; i++) {
    //         minted[i] = _mintedNumbers[i];
    //     }
        
    //     return minted;
    // }   


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
