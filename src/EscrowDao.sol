// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IEscrowFactory} from "src/interfaces/IEscrowFactory.sol";
contract EscrowDao {
    IEscrowFactory public escrowFactory;

    struct Dispute {
        address applicant;
        address otherParty;
        string disputeReason;
        DisputeMessage[] disputeMessage;
    }

    struct DisputeMessage {
        address user;
        string question;
    }

    mapping(address => Dispute) public disputeCreated;

    mapping(address => mapping(address => bool)) public hasVoted;

    constructor(address _escrowAddress) {
        escrowFactory = IEscrowFactory(_escrowAddress);
    }

    modifier onlyContract(address _contractAddress) {
        require(
            _contractAddress.code.length > 0,
            "only contract address can create dao "
        );
        _;
    }

    function createDispute(
        address _contractAddress,
        string memory _reason
    ) external onlyContract(_contractAddress) {
        Dispute memory dispute;
        dispute.applicant = address(0);
        dispute.otherParty = address(0);
        dispute.disputeReason = _reason;
        disputeCreated[_contractAddress] = dispute;
    }

    function sendMessageForDispute(
        address _contractAddress,
        string memory question
    ) external {
        Dispute storage foundDispute = disputeCreated[_contractAddress];
        require(
            foundDispute.applicant != address(0),
            "invalid contract address"
        );
        foundDispute.disputeMessage.push(
            DisputeMessage({user: msg.sender, question: question})
        );
    }

    // function decide
}
