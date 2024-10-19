// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import "./ERC721Facet.sol";

/** 
 * @title MerkleFacet
 * @dev This facet is used for claiming airdrops using merkle proofs. It supports ERC721 tokens and uses the OpenZeppelin library for MerkleProof verification.
*/
contract MerkleFacet {

    event AirdropClaimed(address indexed claimer);

    modifier onlyOwner {
        require(LibDiamond.diamondStorage().contractOwner == msg.sender);
        _;
    }

    /**
        @notice This function allows an account to claim airdrop tokens.
        @dev The claiming process involves verifying the user's eligibility using Merkle proofs, 
            and then transferring the specified amount of tokens to the user if they are validated.
        @param proof An array of bytes32 values that represent a merkle proof proving the claimer's eligibility.
    */
    function mint(bytes32[] calldata proof) public {

        // Ensure the user has not already claimed
        require(!LibDiamond.diamondStorage().hasClaimed[msg.sender], "Airdrop already claimed");

        // Verify the user's eligibility using the Merkle proof
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender))));
        require(MerkleProof.verify(proof, LibDiamond.diamondStorage().merkleRoot, leaf), "Invalid proof");

        uint256 _tokenId = LibDiamond.diamondStorage().tokenId++;

        // Mark the address as having claimed
        LibDiamond.diamondStorage().hasClaimed[msg.sender] = true;

        // Mint the specified amount of tokens to the user
        LibDiamond.diamondStorage().erc721._safeMint(msg.sender, _tokenId);

        // Emit an event to indicate that the airdrop has been claimed
        emit AirdropClaimed(msg.sender);
    }

    // This function is userd to update the merkleRoot of the contract, callable only by the owner
    function updateMerkleRoot(bytes32 newRoot) external onlyOwner {
        LibDiamond.DiamondStorage storage l = LibDiamond.diamondStorage();
        l.merkleRoot = newRoot;
    }

}