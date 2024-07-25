// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EscrowFactory {
    address[] public allEscrowsAddresses;
    address public dao;
    address public owner;
    mapping(address => uint) public balance;
    address public token;
    mapping(address => address[]) public userCreatedEscrow;
    mapping(address => mapping(address => address[])) public userToUserEscrow;

    struct CreateEscrow {
        address _creator;
        address _otherParty;
        uint256 _amount;
        address _tokenUsed;
    }

    function createEscrow(CreateEscrow memory escrow) external {}
}
