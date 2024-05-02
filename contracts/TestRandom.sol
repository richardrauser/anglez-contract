
// TODO: consider license
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Random.sol";

contract TestRandom {

    function randomInt(uint randomSeed, uint min, uint max) external pure returns (uint) {
        return Random.randomInt(randomSeed, min, max);
    }
    
    function randomInt8(uint randomSeed, uint8 min, uint8 max) external pure returns (uint) {
        return Random.randomInt8(randomSeed, min, max);
    }

    function randomColour(uint randomSeed) public pure returns (string memory) {
        return Random.randomColour(randomSeed);
    }
}