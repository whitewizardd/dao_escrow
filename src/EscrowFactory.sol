// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Escrow} from "./Escrow.sol";

contract EscrowFactory {
    address[] public allEscrowsAddresses;
    Escrow[] public escrows;
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

    function createEscrow(CreateEscrow memory _escrow) external {
        Escrow escrow = new Escrow(
            _escrow._creator,
            _escrow._otherParty,
            _escrow._amount,
            _escrow._tokenUsed
        );
        escrows.push(escrow);
        allEscrowsAddresses.push(address(escrow));
        userCreatedEscrow[msg.sender].push(address(escrow));
        userToUserEscrow[msg.sender][_escrow._otherParty];
    }

    function getUserCreatedEscrow()
        external
        view
        returns (address[] memory userCreatedEscrows)
    {
        userCreatedEscrows = userCreatedEscrow[msg.sender];
    }
}
