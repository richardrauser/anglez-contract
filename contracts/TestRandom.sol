
// TODO: consider license
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Random.sol";

contract TestRandom {

    function randomInt(uint randomSeed, uint min, uint max) external pure returns (uint) {
        return Random.randomInt(randomSeed, min, max);
    }

    function randomColour(uint randomSeed) public pure returns (string memory) {
        return Random.randomColour(randomSeed);
    }
}