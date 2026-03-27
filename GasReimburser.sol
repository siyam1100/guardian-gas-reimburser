// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IOptimisticOracle {
    function getAssertionResult(bytes32 assertionId) external view returns (bool);
}

contract GasReimburser is Ownable, ReentrancyGuard {
    IOptimisticOracle public immutable oracle;
    mapping(bytes32 => bool) public claimed;
    
    uint256 public constant GAS_OVERHEAD = 50000; // Buffer for logic execution
    uint256 public constant BOUNTY_PERCENT = 10; // 10% bonus

    event RefundIssued(address indexed guardian, bytes32 indexed assertionId, uint256 amount);

    constructor(address _oracle) Ownable(msg.sender) {
        oracle = IOptimisticOracle(_oracle);
    }

    /**
     * @dev Reimburses a Guardian for gas spent on a successful dispute.
     * @param _assertionId The UMA assertion ID that was successfully disputed.
     */
    function claimReimbursement(bytes32 _assertionId) external nonReentrant {
        require(!claimed[_assertionId], "Already reimbursed");
        
        // In production: verify with UMA that msg.sender was the successful disputer
        bool isWinner = oracle.getAssertionResult(_assertionId);
        require(isWinner, "Only successful disputers can claim");

        claimed[_assertionId] = true;

        // Calculate gas refund (simplified version)
        uint256 gasToRefund = (gasleft() + GAS_OVERHEAD) * tx.gasprice;
        uint256 totalPayout = gasToRefund + (gasToRefund * BOUNTY_PERCENT / 100);

        require(address(this).balance >= totalPayout, "Treasury underfunded");
        
        (bool success, ) = payable(msg.sender).call{value: totalPayout}("");
        require(success, "Payment failed");

        emit RefundIssued(msg.sender, _assertionId, totalPayout);
    }

    receive() external payable {}
}
