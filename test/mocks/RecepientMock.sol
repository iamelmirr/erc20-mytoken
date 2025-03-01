// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MyToken} from "../../src/MyToken.sol";
import {MyTokenTest} from "../MyToken.t.sol";

contract RecipientMock {
    address public lastApprovalSender;
    uint256 public lastApprovalValue;

    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external {
        lastApprovalSender = _from;
        lastApprovalValue = _value;
    }
}
