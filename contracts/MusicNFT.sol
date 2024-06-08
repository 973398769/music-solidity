// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MusicNFT is ERC721A, Ownable {
    using Strings for uint256;

    uint256 public constant PUBLIC_MINTING_PRICE = 1 ether;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) public totalPublicMint;
    // MusicNFTMgr address
    address public platformContractAddress;
    
    constructor(address _platformContractAddress)
        ERC721A("Minted Music NFT", "MNFT")
    {
        platformContractAddress = _platformContractAddress;
    }

    modifier callerIsUser() {
        require(
            tx.origin == msg.sender,
            "Music :: Cannot be called by a contract"
        );
        _;
    }

    function getMintingPrice() public pure returns (uint256) {
        return PUBLIC_MINTING_PRICE;
    }

    function mint(string memory thisTokenURI, uint256 _quantity) public payable callerIsUser {
        require(
            msg.value >= (PUBLIC_MINTING_PRICE * _quantity),
            "Music :: Not enough to mint"
        );

        totalPublicMint[msg.sender] += _quantity;
        uint256 firstMintedIndex = totalSupply();
        _safeMint(msg.sender, _quantity);

        for (uint256 i = 0; i < _quantity; i+=1) {
            _setTokenURI(firstMintedIndex + i, thisTokenURI);
        }

        setApprovalForAll(platformContractAddress, true);
    }

    // return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory tokenUriToReturn = _tokenURIs[tokenId];
    
        return
            bytes(tokenUriToReturn).length > 0
                ? string(
                    tokenUriToReturn
                )
                : "";
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function getContractBalance() public view onlyOwner returns (uint256 balance) {
        return address(this).balance;
    }
}
