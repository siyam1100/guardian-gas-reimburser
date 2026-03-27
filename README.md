# Guardian Gas Reimburser

To ensure a DAO remains secure, the "Security Guardians" must not be penalized by high network fees. This protocol automates the process of "Gas Smoothing," where the DAO Treasury covers the operational costs of successful protocol defense.

## How it Works
1. **Dispute**: The Guardian identifies and stops a malicious assertion.
2. **Proof**: The Guardian calls `claimReimbursement()`, providing the `assertionId`.
3. **Verification**: The contract queries the Oracle to confirm the Guardian won.
4. **Payout**: The contract calculates the gas used (via `tx.gasprice`) and sends a refund + 10% bounty in a stablecoin or ETH.

## Security Features
* **Oracle-Backed**: Only winners of verified disputes can claim.
* **Rate Limiting**: Prevents "Gas Griefing" by capping the maximum refundable gas price.
* **Cooldown**: One reimbursement per successful dispute ID.
