// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ColourWork.sol";

contract TestColourWork {
    function _safeTint(uint colourComponent, uint tintComponent, uint alpha) public pure returns (uint) { 
        return ColourWork.safeTint(colourComponent, tintComponent, alpha);
    }

    function _rgbString(uint red, uint green, uint blue) public pure returns (string memory) { 
        return ColourWork.rgbString(red, green, blue);
    }
}