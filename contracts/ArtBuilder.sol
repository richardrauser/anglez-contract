// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./ArtBuilder.sol";
import "./StringUtils.sol";
import "./Random.sol";
import "./TokenParams.sol";
import "./ColourWork.sol";

import "hardhat/console.sol";

library ArtBuilder {

    function getColour(uint randomSeed, Tint memory tint) private pure returns (string memory) {
        uint red = ColourWork.safeTint(Random.randomInt(randomSeed, 0, 255), tint.red, tint.alpha);
        uint green = ColourWork.safeTint(Random.randomInt(randomSeed + 2, 0, 255), tint.green, tint.alpha);
        uint blue = ColourWork.safeTint(Random.randomInt(randomSeed + 1, 0, 255), tint.blue, tint.alpha);

        return ColourWork.rgbString(red, green, blue);        
    }
    
    function build(TokenParams memory tokenParams) internal pure returns (string memory) {

        if (!tokenParams.custom) {
            // TODO: randomize params

        }
        

        (string memory viewBox, string memory clipRect) = getViewBoxClipRect(150 - tokenParams.zoom);
        string memory defs = string(abi.encodePacked("<defs><clipPath id='masterClip'><rect ", clipRect, "/></clipPath></defs>"));

        uint maxPolyRepeat;

        if (tokenParams.cyclic) {
            maxPolyRepeat = Random.randomInt(tokenParams.randomSeed + 300, 2, 8);             
        } else {
            maxPolyRepeat = 1;
        }


        string memory shapes = getShapes(tokenParams, maxPolyRepeat);
        return string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' viewBox='", 
            viewBox, "'>", 
            defs, "<g clip-path='url(#masterClip)'>", shapes, "</g></svg>"));
    }


    function getViewBoxClipRect(uint zoom) private pure returns (string memory, string memory) {
        zoom = zoom * 10;
        string memory widthHeight = StringUtils.uintToString(500 + zoom);

        if (zoom > 500) {
            string memory offset = StringUtils.uintToString((zoom - 500) / 2);
            string memory viewBox = string(abi.encodePacked("-", offset, " -", offset, " ",  widthHeight, " ", widthHeight));
            string memory clipRect = string(abi.encodePacked("x='-", offset, "' y='-", offset, "' width='",  widthHeight, "' height='", widthHeight, "'"));
            return (viewBox, clipRect);
        } else {
            string memory offset = StringUtils.uintToString((zoom == 500 ? 0 : (500 - zoom) / 2));
            string memory viewBox = string(abi.encodePacked(offset, " ", offset, " ",  widthHeight, " ", widthHeight));
            string memory clipRect = string(abi.encodePacked("x='", offset, "' y='", offset, "' width='",  widthHeight, "' height='", widthHeight, "'"));

            return (viewBox, clipRect);
        }
    }

    function getShapes(TokenParams memory tokenParams, uint maxPolyRepeat) private pure returns (string memory) {
        string memory shapes = "";
        // TODO: consider best max ( 5 15?)
        // console.log('_------- RANDOM SEED: ' + randomSeed);
        uint minX = 1000;
        uint maxX = 0;

        uint randomSeed = tokenParams.randomSeed;

        // polygon loop
        for (uint i = 0; i < tokenParams.shapeCount; i++) {
            console.log('BEGINNING LOOP randomSeed: ');
            console.log(randomSeed);
            uint pointCount = Random.randomInt(randomSeed + i, 3, 5);

            // console.log('polygon: ' + i);
            // console.log('pointCount: ' + pointCount);

            string memory points = "";

            // TODO: folded shapes by repeating points?

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

            uint polygonCount = Random.randomInt(randomSeed + 17, 1, maxPolyRepeat);
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
                    ")' opacity='", 
                    StringUtils.uintToString((maxPolyRepeat < 4 ? Random.randomInt(randomSeed + i + 16, 80, 100) : Random.randomInt(randomSeed + i + 16, 50, 80))), 
                    "%' />"));

                polyRotation += polyRotationDelta;
            }

            uint gradientRotation = Random.randomInt(randomSeed + i + 15, 0, 360);

            shapes = string(abi.encodePacked(shapes, 
                "<linearGradient id='gradient", StringUtils.uintToString(i), "' gradientTransform='rotate(", 
                StringUtils.uintToString(gradientRotation), 
                ")'>",
                "<stop offset='0%' stop-color='", getColour(randomSeed + i + 13, tokenParams.tint), "'/>",
                "<stop offset='50%' stop-color='", getColour(randomSeed + i + 14, tokenParams.tint), "' stop-opacity='", 
                StringUtils.uintToString(midStopOpacity), 
                "%'/>",
                "<stop offset='100%' stop-color='", getColour(randomSeed + i + 15, tokenParams.tint), "'/>",
                "</linearGradient>",
                polygons
            ));

            console.log('randomSeed before incrementing: ');
            console.log(randomSeed);
            randomSeed += 100;
            console.log('randomSeed after incrementing: ');
            console.log(randomSeed);
        }

        return shapes;

    }

    function getTraits(TokenParams memory tokenParams) internal pure returns (string memory) {

        // if (!tokenParams.custom) {
        //     return "";

        // } else {
        //     return "";
        // }

        uint tintAlpha = uint(tokenParams.tint.alpha) * 100 / 255;


        return string(abi.encodePacked('"attributes": [',
            '{"trait_type": "seed", "value": "', StringUtils.uintToString(tokenParams.randomSeed), '"},',
            '{"trait_type": "custom", "value": "', (tokenParams.custom) ? "true" : "false", '"},',
            '{"trait_type": "shapes", "value": "', StringUtils.uintToString(tokenParams.shapeCount), '"},',
            '{"trait_type": "zoom", "value": "', StringUtils.uintToString(tokenParams.zoom), '%"},',
            '{"trait_type": "tint color", "value": "rgb(', StringUtils.uintToString(tokenParams.tint.red), ', ', StringUtils.uintToString(tokenParams.tint.green), ', ', StringUtils.uintToString(tokenParams.tint.blue), ')"},',
            '{"trait_type": "tint transparency", "value": "', StringUtils.uintToString(tintAlpha), '%"},',
            '{"trait_type": "cyclic", "value": "', tokenParams.cyclic ? "true" : "false",'"}',
            ']'));
    }
}