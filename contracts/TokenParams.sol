// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct Tint {
    uint8 red; // 0 - 255
    uint8 green; // 0 - 255
    uint8 blue; // 0 - 255
    uint8 alpha; // 0 - 255
}

struct TokenParams {
    uint24 randomSeed;
    bool custom;
    uint8 zoom; // 0 - 100
    Tint tint;
    uint8 shapeCount; // 1 - 20
    bool cyclic;
}

