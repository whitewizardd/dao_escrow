// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EscrowFactory {
    address[] public allEscrowsAddresses;
    address public dao;
    address public owner;
    mapping(address => uint) public balance;
    address public token;
    mapping(address => address[]) public userCreatedEscrow;
    mapping(address => mapping(address => address[])) public userToUserEscrow;
}
