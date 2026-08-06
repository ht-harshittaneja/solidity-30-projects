// Build a secure signature-based entry system for a private Web3 event, like a conference, workshop, or token-gated meetup. 
// Instead of storing an on-chain whitelist of attendees, your backend or event organizer signs a message for each approved guest. 
// When attendees arrive, they submit their signed message to the smart contract to prove they were invited. 
// The contract uses `ecrecover` to verify the signature on-chain, confirming their identity without needing any prior on-chain registration. 
// This pattern drastically reduces gas costs, keeps the contract lightweight, and mirrors how many real-world events handle off-chain approvals with on-chain validation — a practical Web3 authentication flow.

// # Concepts you will master
// 1. ecrecover
// 2. verifying signatures
// 3. basic authentication

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract SignThis {
    string public workshopName;
    uint256 public workshopId;
    address organizer ;
    mapping (address => bool) hasAttended;

    constructor (address _organizer , string memory _workshopName , uint256 _workshopId){
        organizer = _organizer;
        workshopName = _workshopName ;
        workshopId = _workshopId;
    }

    event Entry(address indexed user , uint256 indexed workshopId, uint256 timestamp);

    function getHash(address _guest) public view returns(bytes32){
        return keccak256(abi.encode(workshopName , workshopId , _guest));
    }

    function splitSig(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v){
        require(sig.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function verify(address _guest, bytes memory _sig) public view returns (bool) {
        bytes32 msgHash = getHash(_guest);
        bytes32 ethHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));

        (bytes32 r, bytes32 s, uint8 v) = splitSig(_sig);
        address signer = ecrecover(ethHash, v, r, s);
        return signer == organizer;
    }

    function joinWorkshop(bytes memory _sig) public {
        require(!hasAttended[msg.sender], "Already entered");
        require(verify(msg.sender, _sig), "Invalid signature");
        hasAttended[msg.sender] = true;
        emit Entry(msg.sender, workshopId, block.timestamp);
    }
}