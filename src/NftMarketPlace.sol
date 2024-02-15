// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./NftCollection.sol";
import "./Receiver.sol";
import "./IterableMap.sol";
import "./Structs.sol";

contract NftMarketPlace is MyERC1155Receiver {
    using IterableMapping for IterableMapping.MapBytes32ToListedToken;

    function generateTokenIdentifier(address _collectionAddress, uint256 _tokenId, address _walletAddress)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_collectionAddress, _tokenId, _walletAddress));
    }

    struct NFTCollection {
        address ownerOfCollection;
        address collectionAddr;
        TokenStructs.OwnedToken[] tokens;
        TokenStructs.ListedToken[] listedTokens;
    }

    //the map is stores the keys to iterate over ListedTokens
    //to create key in typeof bytes32 it use keccak256(abi.encoded( collectionAddr, tokenId, ownerAddr)) function
    //abi.encoded returns byte represantation for parameters
    //keccak256 is a hasher function it will produce bytes32
    //bytes32 => ListedTokens
    IterableMapping.MapBytes32ToListedToken private tokenForSale;

    address[] public collectionAddressArray;

    //creator address to Collection Contract address[] mapping
    mapping(address => mapping(address => NFTCollection)) public ownerCollections;

    uint256 percentageCommission;

    constructor(uint256 feeamount) {
        percentageCommission = feeamount;
    }

    event canceledSale(address collectionAddress, uint256 tokenId, address indexed seller, bool canceled);

    event startSale(
        address tokenOwner, address collectionAddress, string collectionName, uint256 _price, uint256 _tokenId
    );

    event bought(address tokenOwner, address collectionAddress, uint256 _price, uint256 _tokenId);

    function ListedTokenArr(uint256 _tokenId) public {}

    function viewUserCollection(address userAddr, address collectionAddr) public view returns (NFTCollection memory) {
        return ownerCollections[userAddr][collectionAddr];
    }

    function viewNFTs() public view returns (TokenStructs.ListedToken[] memory) {
        return tokenForSale.mapToArray();
    }

    function createCollection(string memory name, string memory tokenSymbol, string memory logo)
        public
        returns (address)
    {
        IERC1155 NFT = new NftCollection(msg.sender, logo);
        collectionAddressArray.push(address(NFT));
        return address(NFT);
    }

    //just for testing with non ownable NftCollection Contracts
    // function mint(address collectionAddr, uint256 tokenId, uint256 amount) public {
    //     NftCollection(collectionAddr).mint(msg.sender, tokenId, amount);
    // }

    //    function isApp(address collectionAddr) public view returns (bool) {
    //     return NftCollection(collectionAddr).isApprovedForAll(msg.sender, address(this));
    // }

    function returnCollections() public view returns (address[] memory) {
        return collectionAddressArray;
    }

    //require(IERC721(nftContractAddress).supportsInterface(0x80ac58cd), "Not an ERC721 contract");

    function startsaleNFT(address collectionAddress, string memory collectionName, uint256 price, uint256 tokenId)
        public
        checkCollectionAddr(collectionAddress)
        checkOwner(collectionAddress, tokenId, msg.sender)
    {
        IERC1155 NFT = IERC1155(collectionAddress);
        NFT.safeTransferFrom(msg.sender, address(this), tokenId, 1, "");
        TokenStructs.ListedToken memory token =
            TokenStructs.ListedToken(TokenStructs.Token(collectionAddress, tokenId), msg.sender, 1, price);
        tokenForSale.set(generateTokenIdentifier(collectionAddress, tokenId, msg.sender), token);
        //emit startsaleNFT(_tokenId, msg.sender, false);
        emit startSale(msg.sender, collectionAddress, collectionName, price, tokenId);
    }

    function cancelSale(address collectionAddress, uint256 tokenId, address tokenOwner)
        public
        checkCollectionAddr(collectionAddress)
        isItListed(collectionAddress, tokenId, tokenOwner)
        checkOwner(collectionAddress, tokenId, tokenOwner)
    {
        IERC1155 NFT = IERC1155(collectionAddress);
        NFT.safeTransferFrom(address(this), msg.sender, tokenId, 1, "");
        tokenForSale.remove(generateTokenIdentifier(collectionAddress, tokenId, msg.sender));

        emit canceledSale(collectionAddress, tokenId, msg.sender, true);
    }

    function buyNFT(address collectionAddress, uint256 tokenId, address tokenOwner)
        public
        payable
        checkCollectionAddr(collectionAddress)
        isItListed(collectionAddress, tokenId, tokenOwner)
        checkOwner(collectionAddress, tokenId, tokenOwner)
    {
        IERC1155 NFT = IERC1155(collectionAddress);
        TokenStructs.ListedToken memory listedToken =
            tokenForSale.get(generateTokenIdentifier(collectionAddress, tokenId, msg.sender));
        require(msg.value >= listedToken.unitPrice, "Not enough ETH sent");

        payable(listedToken.owner).transfer(msg.value);

        NFT.safeTransferFrom(address(this), msg.sender, tokenId, 1, "");

        tokenForSale.remove(generateTokenIdentifier(collectionAddress, tokenId, msg.sender));

        emit bought(msg.sender, collectionAddress, listedToken.unitPrice, listedToken.token.tokenId);
    }

    modifier isItListed(address collectionAddress, uint256 tokenId, address tokenOwner) {
        require(
            tokenForSale.exists[generateTokenIdentifier(collectionAddress, tokenId, tokenOwner)] != false,
            "The Token is Not Listed"
        );
        _;
    }

    modifier checkCollectionAddr(address collectionAddress) {
        require(collectionAddress != address(0), "Invalid collection address");
        _;
    }

    modifier checkOwner(address contractAddress, uint256 tokenId, address tokenOwner) {
        require(ERC1155(contractAddress).balanceOf(tokenOwner, tokenId) > 0, "You are not the owner of NFT!");
        _;
    }
}
