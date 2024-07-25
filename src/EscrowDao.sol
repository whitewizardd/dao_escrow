// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IEscrowFactory} from "src/interfaces/IEscrowFactory.sol";
contract EscrowDao {
    IEscrowFactory public escrowFactory;
    struct Dispute {
        address applicant;
        address otherParty;
        string disputeReason;
        DisputeStatus disputeStatus;
        DisputeMessage[] disputeMessage;
    }

    struct DisputeMessage {
        address user;
        string question;
    }

    enum DisputeStatus {
        CLOSED,
        OPEN
    }

    enum Decision {
        UNDECIDED,
        REFUND,
        CLOSED
    }

    mapping(address => Dispute) public disputeCreated;

    mapping(address => mapping(address => bool)) public hasVoted;
    uint256 public quorum;

    constructor(address _escrowAddress, uint _quorum) {
        escrowFactory = IEscrowFactory(_escrowAddress);
        quorum = _quorum;
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
        dispute.disputeStatus = DisputeStatus.OPEN;
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
        require(
            foundDispute.disputeStatus == DisputeStatus.OPEN,
            "only opened dispute status allowed"
        );
        foundDispute.disputeMessage.push(
            DisputeMessage({user: msg.sender, question: question})
        );
    }

    function voteOnDIspute(
        address _contractAddress,
        Decision decision
    ) external {
        require(!hasVoted[_contractAddress][msg.sender], "already voted");

        if (decision == Decision.REFUND) {}
        if (decision == Decision.CLOSED) {}

        hasVoted[_contractAddress][msg.sender] = true;
    }

    function executeDispute(address _contractAddress) external {}
}
