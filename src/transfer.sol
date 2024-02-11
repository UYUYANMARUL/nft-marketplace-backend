// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMARKET {
    struct Token {
        IERC721 nft;
        uint256 price;
        uint256 tokenId;
        bool sold;
        address[] seller; //hem msg.sender hem approve edilen kişiler satabilir
    }

    mapping(uint256 => Token) public Tokenforsale;

    constructor(uint256 feeamount) {
        percentageCommission = feeamount;
    }

    event startSale(uint256 tokenId, address indexed seller, bool canceled);

    function startsaleNFT(IERC721 NFT, uint256 _price, uint256 _tokenId, address[] memory sellers) public {
        NFT.transferFrom(msg.sender, address(this), _tokenId);
        Tokenforsale[_tokenId] = Token(NFT, _price, _tokenId, false, sellers);

        emit startsaleNFT(_tokenId, msg.sender, false);
    }

    event cancelSale(uint256 tokenId, address indexed seller, bool canceled);

    function cancelSale(IERC721 NFT, uint256 _price, uint256 _tokenId) public {
        NFT.transferFrom(address(this), msg.sender, _tokenId);
        delete Tokenforsale[_tokenId];

        emit cancelSale(_tokenId, msg.sender, true);
    }

    function buyNFT(IERC721 NFT, uint256 tokenId) public payable {
        Token memory token = Tokenforsale[tokenId];
        require(msg.value >= token.price, "Not enough ETH sent");

        for (uint256 i = 0; i < token.sellers.length; i++) {
            payable(token.sellers[i]).transfer(msg.value / token.sellers.length);
        }

        NFT.transferFrom(address(this), msg.sender, tokenId);
        delete Tokenforsale[tokenId];
        token.sold = true;
    }
}
