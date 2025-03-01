// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";

// Copy these from flattened.sol
type PoolId is bytes32;

struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    IHooks hooks;
}

struct Currency {
    address addr;
}

interface IHooks {
    // ... we don't need the full interface for this script
}

library PoolIdLibrary {
    function toId(PoolKey memory key) internal pure returns (PoolId) {
        return PoolId.wrap(keccak256(abi.encode(key)));
    }
}

contract GetPoolId is Script {
    using PoolIdLibrary for PoolKey;

    function run() public view {
        // Transaction details from 0x82cb34d63bc8894d65f2ef218da38e492382c823fe0d7c2882c3f93de2e31999
        address token0 = 0x4200000000000000000000000000000000000006; // WETH
        address token1 = 0x1B82cA1d8cF6061CE62C8b0702EbC3671F5E7Cd7; // USDC
        uint24 fee = 500;
        int24 tickSpacing = 10;
        address hook = 0xC77E884E82Fdc9274Bf17bf28B6c89D05B6d8AC0;  // Fixed checksum

        PoolKey memory key = PoolKey({
            currency0: Currency(token0),
            currency1: Currency(token1),
            fee: fee,
            tickSpacing: tickSpacing,
            hooks: IHooks(hook)
        });

        PoolId id = key.toId();
        console.logBytes32(PoolId.unwrap(id));  // Convert PoolId to bytes32
    }
} 