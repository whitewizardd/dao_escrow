// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "./../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Escrow {
    uint public amount;
    address public creator;
    address public otherParty;
    bool public isEscrowConfirmed;
    EscrowStatus public escrowStatus;
    uint public createdDateTime;
    uint public confirmedDateTime;
    address public escrowFactoryContractAddress;
    ERC20 public tokenAddress;
    using SafeERC20 for ERC20;

    enum EscrowStatus {
        PENDING,
        CONFIRMED,
        CLOSED
    }

    struct EscrowDetails {
        address creator;
        address otherParty;
        uint256 amount;
        EscrowStatus status;
        string tokenName;
    }
    constructor(
        address _creator,
        address _otherParty,
        uint256 _amount,
        address tokenUsed
    ) {
        amount = _amount;
        creator = _creator;
        otherParty = _otherParty;
        escrowStatus = EscrowStatus.PENDING;
        createdDateTime = block.timestamp;
        tokenAddress = ERC20(tokenUsed);
    }

    modifier onlyOtherParty(address user) {
        require(
            user == otherParty,
            "only the other party can perform this action"
        );
        _;
    }

    modifier onlyCreatorOrOtherParty(address user) {
        require(user == creator || user == otherParty);
        _;
    }
    function confirmEscrow(address user) external onlyOtherParty(user) {
        require(escrowStatus == EscrowStatus.PENDING, "escrow not pending");
        escrowStatus = EscrowStatus.CONFIRMED;
        confirmedDateTime = block.timestamp;
        tokenAddress.safeTransferFrom(
            user,
            escrowFactoryContractAddress,
            amount
        );
    }

    function getEscrowDetails()
        external
        view
        onlyCreatorOrOtherParty(msg.sender)
        returns (EscrowDetails memory)
    {
        return
            EscrowDetails({
                creator: creator,
                otherParty: otherParty,
                amount: amount,
                status: escrowStatus,
                tokenName: ERC20(tokenAddress).name()
            });
    }

    function releaseFund(address user) external onlyOtherParty(user) {
        require(
            escrowStatus == EscrowStatus.CONFIRMED,
            "only confirmed escrow"
        );
        tokenAddress.safeTransfer(creator, amount);
        escrowStatus = EscrowStatus.CLOSED;
    }
}
