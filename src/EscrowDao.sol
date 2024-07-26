// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IEscrowFactory} from "./interfaces/IEscrowFactory.sol";
contract EscrowDao {
    IEscrowFactory public escrowFactory;
    struct Dispute {
        address applicant;
        address otherParty;
        string disputeReason;
        DisputeStatus disputeStatus;
        DisputeMessage[] disputeMessage;
        uint CLOSED;
        uint REFUND;
        uint totalCastedDecision;
    }

    struct DisputeMessage {
        address user;
        string question;
    }

    enum DisputeStatus {
        NOT_CREATED,
        CLOSED,
        OPEN
    }

    enum Decision {
        UNDECIDED,
        REFUND,
        CLOSED
    }

    mapping(address => Dispute) public disputeCreated;
    address[] public addressDispute;

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
        address _disputeCreator,
        address _otherParty,
        string memory _reason
    ) external onlyContract(msg.sender) {
        Dispute storage dispute = disputeCreated[msg.sender];
        require(
            dispute.disputeStatus == DisputeStatus.NOT_CREATED,
            "dispute alfready created for this contract"
        );
        dispute.applicant = address(0);
        dispute.otherParty = address(0);
        dispute.disputeReason = _reason;
        dispute.disputeStatus = DisputeStatus.OPEN;
        addressDispute.push(_contractAddress);
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

    function voteOnDispute(
        address _contractAddress,
        Decision decision
    ) external {
        require(!hasVoted[_contractAddress][msg.sender], "already voted");
        hasVoted[_contractAddress][msg.sender] = true;
        Dispute storage dispute = disputeCreated[_contractAddress];
        require(
            dispute.disputeStatus == DisputeStatus.OPEN,
            "only open dispute can be voted on"
        );
        if (decision == Decision.REFUND) {
            dispute.REFUND++;
        }
        if (decision == Decision.CLOSED) {
            dispute.CLOSED++;
        }
        dispute.totalCastedDecision++;
    }

    function executeDispute(address _contractAddress) external {}

    function getDisputeMessages(
        address _contractAddress
    ) external view returns (DisputeMessage[] memory) {
        Dispute storage dispute = disputeCreated[_contractAddress];
        return dispute.disputeMessage;
    }

    function getDispute(
        address _contractAddress
    ) external view returns (Dispute memory) {
        return disputeCreated[_contractAddress];
    }
}
