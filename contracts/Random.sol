// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./StringUtils.sol";

library Random {

    function randomIntStr(uint randomSeed, uint min, uint max) internal pure returns (string memory) {
        return StringUtils.uintToString(randomInt(randomSeed, min, max));
    }

    function randomInt8(uint randomSeed, uint min, uint max) internal pure returns (uint8) {
        if (max <= min) {
            return uint8(min);
        }

        uint seed = uint(keccak256(abi.encode(randomSeed)));
        uint modulus = max - min + 1;
        uint result = uint(seed % modulus) + min;
        return uint8(result);
    }

    function randomInt(uint randomSeed, uint min, uint max) internal pure returns (uint) {
        if (max <= min) {
            return min;
        }

        uint seed = uint(keccak256(abi.encode(randomSeed)));
        return uint(seed % (max - min + 1)) + min;
    }
    

    // TODO: does this match js?
    function randomColour(uint randomSeed) internal pure returns (string memory) {
        return StringUtils.rgbString(randomInt(randomSeed, 100, 255), randomInt(randomSeed + 101, 0, 255), randomInt(randomSeed + 102, 0, 255));        
    }
}