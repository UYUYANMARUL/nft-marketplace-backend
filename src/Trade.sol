// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Trade {
    IERC1155 private NFT;

    constructor(address nftAddress) {
        NFT = IERC1155(nftAddress);
    }

    enum OfferState {
        PENDING,
        ACCEPTED,
        CANCELLED
    }

    struct Offer {
        uint256[] tokenIDsCreator;
        uint256[] tokenIDsAcceptor;
        address creatorAddress;
        address acceptorAddress;
        uint256 amountCreator;
        uint256 amountAcceptor;
        OfferState state;
        uint256 deadline;
    }

    uint256 time = block.timestamp;

    Offer[] public offers;

    event OfferCreated(uint256 offerIndex);
    event OfferAccepted(uint256 offerIndex);

    function createOffer(
        uint256[] memory _tokenIDsCreator,
        uint256[] memory _tokenIDsAcceptor,
        address _creatorId,
        address _acceptorId,
        uint256 _amountCreator,
        uint256 _amountAcceptor,
        OfferState _state,
        uint256 _closeTime
    )
        public
        payable
        CreatorTokenCheck(_tokenIDsCreator, _creatorId)
        AcceptorTokenCheck(_tokenIDsAcceptor, _acceptorId)
        returns (bool)
    {
        require(msg.value >= _amountCreator, "not enough balance");
        require(_closeTime >= 60, ".....");
        uint256 deadline = block.timestamp + _closeTime;
        offers.push(
            Offer(
                _tokenIDsCreator,
                _tokenIDsAcceptor,
                _creatorId,
                _acceptorId,
                _amountCreator,
                _amountAcceptor,
                OfferState.PENDING,
                deadline
            )
        );

        emit OfferCreated(offers.length - 1);
        return true;
    }

    function acceptOffer(
        uint256 _offerIndex,
        address _creatorAddress,
        address _acceptorAddress,
        uint256[] memory _tokenIDsCreator,
        uint256[] memory _tokenIDsAcceptor
    ) public AcceptorTokenCheck(_tokenIDsAcceptor, _acceptorAddress) timeCheck(_offerIndex) returns (string memory) {
        offers[_offerIndex].state = OfferState.ACCEPTED;

        // Transfer tokens from creator to acceptor
        for (uint256 i = 0; i < _tokenIDsCreator.length; i++) {
            NFT.safeTransferFrom(_creatorAddress, _acceptorAddress, _tokenIDsCreator[i], 1, "");
        }

        // Transfer tokens from acceptor to creator
        for (uint256 i = 0; i < _tokenIDsAcceptor.length; i++) {
            NFT.safeTransferFrom(_acceptorAddress, _creatorAddress, _tokenIDsAcceptor[i], 1, "");
        }

        emit OfferAccepted(_offerIndex);
        return "Offer accepted";
    }

    function cancelOffer(uint256 _offerIndex) public returns (string memory) {
        offers[_offerIndex].state = OfferState.CANCELLED;
        return "Offer canceled";
    }

    function isItOwnerTheTokens(uint256[] memory tokenIds, address _address) public view returns (bool) {
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 balance = NFT.balanceOf(_address, tokenIds[i]);
            if (balance == 0) {
                return false;
            }
        }
        return true;
    }

    modifier AcceptorTokenCheck(uint256[] memory tokenIds, address addr) {
        require(isItOwnerTheTokens(tokenIds, addr), "Acceptor does not have these tokens");
        _;
    }

    modifier CreatorTokenCheck(uint256[] memory tokenIds, address addr) {
        require(isItOwnerTheTokens(tokenIds, addr), "Creator does not have these tokens");
        _;
    }

    modifier timeCheck(uint256 _offerIndex) {
        require(block.timestamp < time + offers[_offerIndex].deadline, "Too late");
        _;
    }
}
