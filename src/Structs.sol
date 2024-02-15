// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface TokenStructs {
    struct Token {
        address collectionAddr;
        uint256 tokenId;
    }

    struct TokenOwner {
        address ownerAddr;
        uint256 amount;
    }

    struct OwnedToken {
        Token token;
        TokenOwner[] owners;
    }

    struct ListedToken {
        Token token;
        address owner;
        uint256 amount;
        uint256 unitPrice;
    }
}
