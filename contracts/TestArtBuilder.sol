// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ArtBuilder.sol";

contract TestArtBuilder {
      
    function _getTraits(TokenParams memory tokenParams) public pure returns (string memory) {
      return ArtBuilder.getTraits(tokenParams);
    }

    function _sqrt(uint x) public pure returns (uint) {
        return ArtBuilder.sqrt(x);
    }

}