# Uniswap V4 Hook Implementation

This repository contains an implementation of custom hooks for Uniswap V4 on Base. The hooks are designed to track swap metrics and provide additional liquidity management functionality.

## Overview

This project demonstrates the implementation of Uniswap V4 hooks, specifically:

- A `SwapHook` that tracks swap counts before and after swaps
- Deployment scripts for deterministic CREATE2 deployments
- Hook verification tools
- Pool ID calculation utilities

## Project Structure

- `src/` - Contains the hook implementation contracts
  - `SwapHook.sol` - Main hook implementation
  - `CounterHook.sol` - An example hook that counts various operations
- `script/` - Contains deployment and verification scripts
  - `DeployHook.s.sol` - Deploys the hook using CREATE2 for deterministic addresses
  - `VerifyHook.s.sol` - Helps verify the hook contract on Basescan
  - `GetPoolId.s.sol` - Utility to calculate pool IDs

## Prerequisites

- [Foundry](https://book.getfoundry.sh/) for development, testing, and deployment
- A wallet with ETH on Base
- Base RPC URL

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/YOUR_USERNAME/v4-Working.git
   cd v4-Working
   ```

2. Install dependencies:
   ```
   forge install
   ```

## Deployment

To deploy the hook, run:

```bash
# Set your private key as an environment variable
export PRIVATE_KEY=your_private_key

# Deploy to Base mainnet
forge script script/DeployHook.s.sol:Deployhook --rpc-url https://mainnet.base.org --broadcast --verify
```

The deployment script:
1. Uses the CREATE2 factory at `0x0000000000FFe8B47B3e2130213B802212439497`
2. Mines for an address that includes the required hook flags
3. Deploys the hook contract deterministically with specific permissions

## Hook Verification

After deployment, verify the hook contract on Basescan:

```bash
# Set your Base API key
export BASE_API_KEY=your_base_api_key

# Run the verification script
forge script script/VerifyHook.s.sol:VerifyHook --rpc-url https://mainnet.base.org
```

Make sure to update the contract address in `VerifyHook.s.sol` to match your deployed hook.

## Getting Pool IDs

To calculate the Pool ID for a specific pool configuration:

```bash
forge script script/GetPoolId.s.sol:GetPoolId --rpc-url https://mainnet.base.org
```

## Hook Features

The `SwapHook` implements:
- `beforeSwap` and `afterSwap` hooks that track swap counts for each pool
- `beforeAddLiquidity` and `beforeRemoveLiquidity` hooks for liquidity management

## Security Considerations

- This code is provided as an example and has not undergone a formal security audit
- Exercise caution when deploying to production environments
- Test thoroughly on testnets before mainnet deployment

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Uniswap V4 Core](https://github.com/Uniswap/v4-core)
- [Uniswap V4 Periphery](https://github.com/Uniswap/v4-periphery)
