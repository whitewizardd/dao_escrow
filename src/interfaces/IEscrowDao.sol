// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEscrowDao {
    function createDispute(
        address _disputeCreator,
        address _otherParty,
        string memory _reason
    ) external;
}
