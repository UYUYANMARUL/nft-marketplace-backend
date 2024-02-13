// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./NftCollection.sol";

contract NftMarketPlace {
    struct UnListedToken {
        address tokenOwner;
        address collectionAddress;
        string collectionName;
        uint256 price;
        uint256 tokenId;
        address[] seller;
    }

    struct ListedToken {
        address tokenOwner;
        address collectionAddress;
        string collectionName;
        uint256 price;
        uint256 tokenId;
        address[] sellers;
    }

    struct NFTCollection {
        string owner;
        string collectionName;
        address collectionAddress;
        UnListedToken[] unlistedTokens;
        ListedToken[] listedTokens;
    }

    mapping(uint256 => ListedToken) public Tokenforsale;
    ListedToken[] public ArrayTokenforsale;
    uint256 percentageCommission;

    //creator address to Collection Contract address[] mapping
    mapping(address => mapping(address => NFTCollection)) public ownerCollections;

    constructor(uint256 feeamount) {
        percentageCommission = feeamount;
    }

    // event startSale(uint256 tokenId, address indexed seller, bool canceled);
    event cancelSale(address collectionAddress, uint256 tokenId, address indexed seller, bool canceled);
    event startSale(
        address tokenOwner,
        address collectionAddress,
        string collectionName,
        uint256 _price,
        uint256 _tokenId,
        address[] sellers
    );
    event bought(
        address tokenOwner,
        address collectionAddress,
        string collectionName,
        uint256 _price,
        uint256 _tokenId,
        address[] sellers
    );

    function ListedTokenArr(uint256 _tokenId) public {}

    function viewCollection(address userAddr, address collectionAddr) public view returns (NFTCollection memory) {
        return ownerCollections[userAddr][collectionAddr];
    }

    // function viewNFTs() public view returns (ListedToken) {
    //     return Listed;
    // }

    //kişinin koleksiyonuions[collectionName]ksiyon içeriği göster
    //listelenmiş NFT göster
    //listelenmemiş NFT

    function startsaleNFT(
        address tokenOwner,
        address collectionAddress,
        string memory collectionName,
        uint256 _price,
        uint256 _tokenId,
        address[] memory sellers
    ) public checkCollectionAddr(collectionAddress) {
        IERC1155 NFT = IERC1155(collectionAddress);
        NFT.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "");
        Tokenforsale[_tokenId] = ListedToken(tokenOwner, collectionAddress, collectionName, _price, _tokenId, sellers);

        //emit startsaleNFT(_tokenId, msg.sender, false);
        emit startSale(tokenOwner, collectionAddress, collectionName, _price, _tokenId, sellers);
    }

    // function cancelSale(address collectionAddress, uint256 _tokenId) public checkCollectionAddr(collectionAddress) {
    //     IERC1155 NFT = IERC1155(colllectionAddress);
    //     NFT.transferFrom(address(this), msg.sender, _tokenId);
    //     delete Tokenforsale[_tokenId];
    //
    //     emit cancelSale(_tokenId, msg.sender, true);
    // }

    function buyNFT(address collectionAddress, uint256 tokenId) public payable checkCollectionAddr(collectionAddress) {
        IERC1155 NFT = IERC1155(collectionAddress);
        ListedToken memory token = Tokenforsale[tokenId];
        require(msg.value >= token.price, "Not enough ETH sent");

        for (uint256 i = 0; i < token.sellers.length; i++) {
            payable(token.sellers[i]).transfer(msg.value / token.sellers.length);
        }

        NFT.safeTransferFrom(address(this), msg.sender, tokenId, 1, "");
        delete Tokenforsale[tokenId];
        emit bought(token.tokenOwner, collectionAddress, token.collectionName, token.price, tokenId, token.sellers);
    }

    modifier isItListed(uint256 _tokenId) {
        require(Tokenforsale[_tokenId] != bytes4(0x0), "The Token is Not Listed");
        _;
    }

    modifier checkCollectionAddr(address collectionAddress) {
        require(collectionAddress != 0, "Invalid collection address");
        _;
    }
}
