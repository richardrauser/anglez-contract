// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./ArtBuilder.sol";
import "./StringUtils.sol";
import "./Random.sol";
import "./TokenParams.sol";
import "./ColourWork.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

library ArtBuilder {

    function getColour(uint randomSeed, Tint memory tint) private pure returns (string memory) {
        uint red = ColourWork.safeTint(Random.randomInt(randomSeed, 0, 255), tint.red, tint.alpha);
        uint green = ColourWork.safeTint(Random.randomInt(randomSeed + 2, 0, 255), tint.green, tint.alpha);
        uint blue = ColourWork.safeTint(Random.randomInt(randomSeed + 1, 0, 255), tint.blue, tint.alpha);

        return ColourWork.rgbString(red, green, blue);        
    }
    
    function build(TokenParams memory tokenParams) internal pure returns (string memory) {
        uint maxPolyRepeat;

        if (tokenParams.cyclic) {
            maxPolyRepeat = Random.randomInt(tokenParams.randomSeed + 300, 2, 8);             
        } else {
            maxPolyRepeat = 1;
        }

        (string memory shapes, string memory viewBox) = getShapes(tokenParams, maxPolyRepeat);
        return string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' viewBox='", 
            viewBox, "'>", 
            shapes, "</svg>"));
    }

    function getShapes(TokenParams memory tokenParams, uint maxPolyRepeat) private pure returns (string memory, string memory) {
        string memory shapes = "";
        // console.log('_------- RANDOM SEED: ' + randomSeed);
        uint minX = 1000;
        uint maxX = 0;
        uint minY = 1000;
        uint maxY = 0;

        uint randomSeed = tokenParams.randomSeed;

        // polygon loop
        for (uint i = 0; i < tokenParams.shapeCount; i++) {
            console.log('BEGINNING LOOP randomSeed: ');
            console.log(randomSeed);
            uint pointCount = Random.randomInt(randomSeed + i, 3, 4);

            // console.log('polygon: ' + i);
            // console.log('pointCount: ' + pointCount);

            string memory points = "";

            // points loop
            for (uint j = 0; j < pointCount; j++) {
                uint x = Random.randomInt(randomSeed + i + j + 40, 0, 1000);
                uint y = Random.randomInt(randomSeed + i + j + 50, 0, 1000);
                points = string(abi.encodePacked(points, 
                    StringUtils.uintToString(x), 
                    ",", 
                    StringUtils.uintToString(y), 
                    " "));

                if (x > maxX) {
                    maxX = x;
                }
                if (x < minX) {
                    minX = x;
                }
                if (y < minY) {
                    minY = y;
                }
                if (y > maxY) {
                    maxY = y;
                }
            }

            console.log("points");
            console.log(i);
            console.log(points);
            
            uint polygonOpacity;
            uint midStopOpacity;

            if (maxPolyRepeat < 4) {
                polygonOpacity = Random.randomInt(randomSeed + i + 16, 80, 100);
                midStopOpacity = Random.randomInt(randomSeed + i + 20, 40, 90);
            } else {
                polygonOpacity = Random.randomInt(randomSeed + i + 16, 50, 80);
                midStopOpacity = Random.randomInt(randomSeed + i + 20, 30, 90);
            }

            // console.log(`gradientColour1: ${gradientColour1}`);
            // console.log(`gradientColour2: ${gradientColour2}`);
            // console.log(`gradientColour3: ${gradientColour3}`);



            // console.log('gradientRotation: ' + gradientRotation);

            uint polygonCount = maxPolyRepeat == 1 ? 1 : Random.randomInt(randomSeed + 17, 2, maxPolyRepeat);
            string memory polygons = "";
            uint polyRotation = 0;
            uint polyRotationDelta = 360 / polygonCount; //randomIntFromInterval(randomSeed + 18, 10, 180);

            for (uint k = 0; k < polygonCount; k++) {
                polygons = string(abi.encodePacked(polygons, 
                    "<polygon points='", points, 
                    "' transform='rotate(", 
                    StringUtils.uintToString(polyRotation), 
                    ", 500, 500)' fill='url(#gradient", 
                    StringUtils.uintToString(i), 
                    ")' opacity='0.", 
                    StringUtils.uintToString((maxPolyRepeat < 4 ? Random.randomInt(randomSeed + i + 16, 80, 100) : Random.randomInt(randomSeed + i + 16, 50, 80))), 
                    "' />"));

                polyRotation += polyRotationDelta;
            }

            uint gradientRotation = Random.randomInt(randomSeed + i + 15, 0, 360);

            shapes = string(abi.encodePacked(shapes, 
                "<linearGradient id='gradient", StringUtils.uintToString(i), "' gradientTransform='rotate(", 
                StringUtils.uintToString(gradientRotation), 
                ")'>",
                "<stop offset='0%' stop-color='", getColour(randomSeed + i + 13, tokenParams.tint), "'/>",
                "<stop offset='50%' stop-color='", getColour(randomSeed + i + 14, tokenParams.tint), "' stop-opacity='0.", 
                StringUtils.uintToString(midStopOpacity), 
                "'/>",
                "<stop offset='100%' stop-color='", getColour(randomSeed + i + 15, tokenParams.tint), "'/>",
                "</linearGradient>",
                polygons
            ));

            console.log('randomSeed before incrementing: ');
            console.log(randomSeed);
            if (tokenParams.chaotic) {
                randomSeed += 100;
            }
            console.log('randomSeed after incrementing: ');
            console.log(randomSeed);
        }

        uint structureWidth = maxX - minX;
        uint structureHeight = maxY - minY;

        uint width;
        uint height;
        int xOffset;
        int yOffset;

        if (maxPolyRepeat == 1) {
            width = structureWidth + 100;
            xOffset = int(minX) - 50; // (1000 - width) / 2;
            height = structureHeight + 100;
            yOffset = int(minY) - 50;

            // shapes += `
            //   <rect x="${minX}" y="${minY}" width="${structureWidth}" height="${structureHeight}" fill="#f00" opacity="0.2"/>
            // `;
        } else {
            uint margin = min(minX, 1000 - maxX, minY, 1000 - maxY) + 10;
            uint artboardWidthHeight = 1000 - 2 * margin;

            console.log('artboardWidthHeight!: ');
            console.log(artboardWidthHeight);

            uint temp = 2 * (artboardWidthHeight**2);
            console.log('temp: ');
            console.log(temp);
            // so we always have an even number
            uint widthHeight = (sqrt(temp) + 1) / 2 * 2;

            console.log('widthHeight: ');
            console.log(widthHeight);

            int offset = (1000 - int(widthHeight)) / 2;

            width = widthHeight;
            xOffset = offset;
            height = widthHeight;
            yOffset = offset;
        }

        string memory viewBox = string(abi.encodePacked(Strings.toStringSigned(xOffset), ' ', Strings.toStringSigned(yOffset), ' ', StringUtils.uintToString(width), ' ', StringUtils.uintToString(height)));

        return(shapes, viewBox);

    }

    function sqrt(uint x) internal pure returns (uint) {
        uint z = (x + 1) / 2;
        uint y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

      return y;
        
    }
    function min(uint a, uint b, uint c, uint d) internal pure returns (uint) {
        uint minVal = a < b ? a : b;
        minVal = minVal < c ? minVal : c;
        minVal = minVal < d ? minVal : d;

        return minVal;
    }

    function getTraits(TokenParams memory tokenParams) internal pure returns (string memory) {

        uint tintAlpha = uint(tokenParams.tint.alpha) * 100 / 255;

        return string(abi.encodePacked('"attributes": [',
            '{"trait_type": "seed", "value": "', StringUtils.uintToString(tokenParams.randomSeed), '"},',
            '{"trait_type": "custom", "value": "', (tokenParams.custom) ? "true" : "false", '"},',
            '{"trait_type": "shapes", "value": "', StringUtils.uintToString(tokenParams.shapeCount), '"},',
             // TODO: ensure percentages show up properly in opensea
            '{"trait_type": "tint color", "value": "rgb(', StringUtils.uintToString(tokenParams.tint.red), ', ', StringUtils.uintToString(tokenParams.tint.green), ', ', StringUtils.uintToString(tokenParams.tint.blue), ')"},',
            '{"trait_type": "tint opacity", "value": "0.', StringUtils.uintToString(tintAlpha), '"},',
            '{"trait_type": "style", "value": "', tokenParams.cyclic ? "cyclic" : "linear",'"},',
            '{"trait_type": "structure", "value": "', tokenParams.chaotic ? "chaotic" : "folded",'"}',
            ']'));
    }
}