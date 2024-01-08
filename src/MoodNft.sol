// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__CantFlipMoodIfNotOwner();
    enum Mood {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory sadSvgImageUri,
        string memory happySvgImageUri
    ) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageUri;
        s_happySvgImageUri = happySvgImageUri;
    }

    function flipMood(uint256 tokenId) public {
        if (!_isAuthorized(_ownerOf(tokenId), msg.sender, tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function mintNFT() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                name(),
                                '", "description": "An NFT that reflects the owners mood.", "attrbutes":[{"trait_type": "moodiness"}, {"value": 100}], "image": "',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
