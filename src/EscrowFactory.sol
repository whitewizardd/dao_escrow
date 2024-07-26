// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Escrow} from "./Escrow.sol";

contract EscrowFactory {
    address[] public allEscrowsAddresses;
    Escrow[] public escrows;
    address public dao;
    address public owner;
    mapping(address => uint) public balance;
    address[] public tokens;
    mapping(address => address[]) public userCreatedEscrow;
    mapping(address => mapping(address => address[])) public userToUserEscrow;

    struct CreateEscrow {
        address _creator;
        address _otherParty;
        uint256 _amount;
        address _tokenUsed;
    }

    function onlyEscrowAllowedToken(
        address _tokenUsed
    ) private view returns (bool) {
        for (uint index = 0; index < tokens.length; index++) {
            if (tokens[index] == _tokenUsed) return true;
        }
        return false;
    }

    function createEscrow(CreateEscrow memory _escrow) external {
        require(
            onlyEscrowAllowedToken(_escrow._tokenUsed),
            "token not supported."
        );
        Escrow escrow = new Escrow(
            _escrow._creator,
            _escrow._otherParty,
            _escrow._amount,
            _escrow._tokenUsed,
            dao
        );
        escrows.push(escrow);
        allEscrowsAddresses.push(address(escrow));
        userCreatedEscrow[msg.sender].push(address(escrow));
        userToUserEscrow[msg.sender][_escrow._otherParty];
    }

    function getUserCreatedEscrow() external view returns (address[] memory) {
        return userCreatedEscrow[msg.sender];
    }
}
