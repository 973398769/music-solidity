//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MusicNFT.sol";

contract MusicNFTMgr is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _trackIds;

  address payable public owner;
  uint256 public trackListingPrice = 1 ether; // 1 matic

  constructor() {
    owner = payable(msg.sender);
  }

  // record basic information of every minted music NFT
  struct TrackListing {
    uint256 trackId;
    address nftContract;
    uint256 tokenId;
    address payable artist;
    address payable owner;
  }


  mapping(uint256 => TrackListing) private idToTrackListing;

  event TrackListingCreated(
    uint256 indexed trackId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address artist,
    address owner
  );

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
    require(owner == msg.sender, "Ccaller is not the owner");
    _;
    }

  function getTrackListingPrice() public view returns (uint256) {
    return trackListingPrice;
  }

  // return nums of minted music count
  function getNumTrackListings() public view returns (uint256) {
    return _trackIds.current();
  }

  // create a new tracking list
  function createTrackListing(
    address nftContract,
    uint256 tokenId
  ) public payable nonReentrant {
    require(msg.value >= trackListingPrice, "Price must be equal to listing price");

    uint256 trackId = _trackIds.current();
    _trackIds.increment();

    idToTrackListing[trackId] = TrackListing(
      trackId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(msg.sender)
    );

    // MusicNFT tokenContract = MusicNFT(nftContract);
    // tokenContract.safeTransferFrom(msg.sender, address(this), tokenId);

    payable(owner).transfer(msg.value);

    emit TrackListingCreated(
      trackId,
      nftContract,
      tokenId,
      msg.sender,
      msg.sender
    );
  }

  // return information of all minted music list
  function fetchTrackListings() public view returns (TrackListing[] memory) {
    uint256 trackCount = _trackIds.current();

    TrackListing[] memory tracks = new TrackListing[](trackCount);
    for (uint256 i = 0; i < trackCount; i++) {
        TrackListing storage currentTrack = idToTrackListing[i];
        tracks[i] = currentTrack;
    }
    return tracks;
  }

   function getContractBalance() public view onlyOwner returns (uint256 balance) {
        return address(this).balance;
    }
}
