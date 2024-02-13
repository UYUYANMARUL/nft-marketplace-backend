// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./NftCollection.sol";

contract Auction {
    address public owner;
    uint256 immutable fee;
    uint256 public constant mintimeForAuction = 1 days;
    uint256 public immutable timeAdditionForAuction;
    address public highestBidder;
    uint256 public highestBid;

    constructor(uint256 feeAmount, uint256 _time) {
        owner = msg.sender;
        fee = feeAmount;
        timeAdditionForAuction = _time;
    }

    struct itemforsale {
        address contractAddress;
        address sellerAdress;
        address buyerAdress;
        uint256 price;
        uint256 tokenId;
    }

    mapping(uint256 => itemforsale) public forsaleNFT;

    function sellNFT() public payable returns (uint256) {}

    struct auctionItem {
        address contractAddress;
        address sellerAdress;
        address buyerAdress;
        uint256 priceOffer;
        uint256 tokenId;
        address maxOffer;
    }

    mapping(uint256 => auctionItem) public forauctionNFT;

    function startAuction(
        address contractAddress,
        address _seller,
        address _buyer,
        uint256 _priceOffer,
        uint256 _tokenId,
        address _maxOffer
    ) public {
        IERC1155 NFT = IERC1155(contractAddress);
        NFT.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "");
        forauctionNFT[_tokenId] = auctionItem(contractAddress, _seller, _buyer, _priceOffer, _tokenId, _maxOffer);
    }

    function cancelAuction(address contractAddress, uint256 _tokenId) public {
        IERC1155 NFT = IERC1155(contractAddress);
        NFT.safeTransferFrom(address(this), msg.sender, _tokenId, 1, "");
        delete forauctionNFT[_tokenId];
    }

    function auction(address contractAddress, address _seller, address _buyer, uint256 _priceOffer, uint256 _tokenId)
        public
        payable
    {
        IERC1155 NFT = IERC1155(contractAddress);
        auctionItem memory auction = forauctionNFT[_tokenId];
        require(block.timestamp <= mintimeForAuction + timeAdditionForAuction, "sureniz doldu");
        require(msg.value > highestBid, "");
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }
    //
    // function takeNFT(address contractAddress) public payable {
    //     IERC1155 NFT = IERC1155(contractAddress);
    //     NFT.transferFrom(address(this), maxOfferAddr, _tokenId);
    //     payable(_seller).transfer(highOffer);
    // }
}
