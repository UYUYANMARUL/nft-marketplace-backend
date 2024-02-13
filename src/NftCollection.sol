pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftCollection is ERC1155URIStorage, Ownable {
    constructor(address owner, string memory _uri) ERC1155(_uri) Ownable(owner) {}

    function mint(address to, uint256 tokenId, uint256 amount) public onlyOwner {
        _mint(msg.sender, tokenId, amount, "");
    }
}
