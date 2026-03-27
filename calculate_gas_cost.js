const { ethers } = require("ethers");

/**
 * Utility to estimate the potential refund for a dispute transaction.
 */
async function estimateRefund(gasUsed, currentGasPrice) {
    const gasPriceInGwei = ethers.formatUnits(currentGasPrice, "gwei");
    const totalCost = BigInt(gasUsed) * BigInt(currentGasPrice);
    
    console.log(`Estimated Gas Used: ${gasUsed}`);
    console.log(`Current Gas Price: ${gasPriceInGwei} Gwei`);
    console.log(`Total Refund (incl. 10% bonus): ${ethers.formatEther(totalCost * 110n / 100n)} ETH`);
}

// Example: 250k gas at 20 Gwei
estimateRefund(250000, ethers.parseUnits("20", "gwei"));
