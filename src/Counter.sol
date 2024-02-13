// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftMarketPlace {
    address public owner;
    uint256 immutable fee;

    constructor(uint256 feeAmount) {
        owner = msg.sender;
        fee = feeAmount;
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
        uint256 price;
        uint256 tokenId;
    }

    mapping(uint256 => auctionItem) public forautionNFT;
}

contract trade {
    enum OfferState {
        pending,
        accepted,
        canceled
    }

    struct Offer {
        uint256[] tokenIDsSender;
        uint256[] tokenIDsTaker;
        uint256 senderId;
        uint256 takerId;
        uint256 amountSender;
        uint256 amountBuyer;
        bool takerState;
        offerState state;
        uint256 deadline;
    }

    Offer[] public offers;

    mapping(address => uint256) public balances;
    balances SenderBalance;
    balances BuyerBalance;

    event OfferCreated(uint256 offerIndex);

    function createOffer(
        uint256[] memory _tokenIDsSender,
        uint256[] memory _tokenIDsTaker,
        uint256 _senderId,
        uint256 _takerId,
        uint256 _amountSender,
        uint256 _amountBuyer,
        bool _takerState,
        offerState _state,
        uint256 _deadline
    ) public payable returns (bool) {
        require(ownerOf(_tokenIDsender) = "Sendertokens");
        require(ownerOf(_tokenIDsender) = "Buyertokens");
        require(balance >= _amountSender, "not enough balance");
        offers.push(
            Offer(
                _tokenIDsSender,
                _tokenIDsTaker,
                _senderId,
                _takerId,
                _amountSender,
                _amountBuyer,
                _takerState,
                OfferState.pending,
                _deadline
            )
        );

        uint256 time = block.timestamp;

        emit OfferCreated(offers.length - 1);
        return true;
    }

    function acceptOffer(uint256 _offerIndex) public timeCheck returns (string) {
        offers[_offerIndex].state = OfferState.accpeted;
        return "Offer accepted";
    }

    function cancelOffer(uint256 _offerIndex) public timeCheck returns (string) {
        offers[_offerIndex].state = OfferState.canceled;
        return "Offer canceled";
    }

    function Offer(Offer[] offers) {}

    modifier timeCheck() {
        require(block.timestamp < time + offers[_offeerIndex].deadline, "Too late");
        _;
    }
}
