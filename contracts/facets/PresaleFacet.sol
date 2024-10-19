// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "./ERC721Facet.sol";

/** 
 * @title PresaleFacet
 * @dev This facet is used for claiming airdrops using merkle proofs. It supports ERC721 tokens and uses the OpenZeppelin library for MerkleProof verification.
*/
contract PresaleFacet {

    event PresaleClaimed(address indexed claimer, uint256 amount);

    modifier onlyOwner {
        require(LibDiamond.diamondStorage().contractOwner == msg.sender);
        _;
    }

    // Mapping to track if an address has already claimed
    mapping(address => bool) public hasClaimed;

    /**
        @notice This function allows an account to claim airdrop tokens.
        @dev The claiming process involves verifying the user's eligibility using Merkle proofs, 
            and then transferring the specified amount of tokens to the user if they are validated.
        @param _amount The amount of tokens to be claimed by the caller.
    */
     function buyPresale(uint256 _amount) external payable {
        LibDiamond.DiamondStorage storage l = LibDiamond.diamondStorage();
        require(_amount >= l.minPurchase, "Below minimum purchase amount");
        require(_amount <= l.maxPurchase, "Exceeds maximum purchase amount");
        require(msg.value >= _amount * l.presalePrice, "Insufficient payment");

        uint256 _tokenId = LibDiamond.diamondStorage().tokenId++;

        for (uint256 i = 0; i < _amount; i++) {
            ERC721Facet._safeMint(msg.sender, _tokenId);
            _tokenId++;
        }
    }

}