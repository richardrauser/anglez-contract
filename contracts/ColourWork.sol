// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./StringUtils.sol";

library ColourWork {

    function safeTint(uint colourComponent, uint tintComponent, uint alpha) internal pure returns (uint) {        
        unchecked {
            if (alpha == 0) {
                return uint8(colourComponent);
            }
            uint safelyTinted;

            if (colourComponent <= tintComponent) {
                uint offset = ((tintComponent - colourComponent) * alpha) / 255; 
                safelyTinted = colourComponent + offset;            
            } else {
                uint offset = ((colourComponent - tintComponent) * alpha) / 255; 
                safelyTinted = colourComponent - offset;
            }

            return uint8(safelyTinted);            
        }
    }   

    function rgbString(uint red, uint green, uint blue) internal pure returns (string memory) {
        return string(abi.encodePacked("rgb(", StringUtils.smallUintToString(red), ", ", StringUtils.smallUintToString(green), ", ", StringUtils.smallUintToString(blue), ")"));
    }
}