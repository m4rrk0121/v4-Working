// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

library HookMiner {
    uint160 constant HOOK_MASK = 0x3FFF;  // 14-bit mask for all hook flags

    function find(address deployer, uint160 flags, bytes memory creationCode, bytes memory constructorArgs)
        internal
        pure
        returns (address, bytes32)
    {
        bytes32 initCodeHash = keccak256(bytes.concat(creationCode, constructorArgs));
        bytes1 prefix = bytes1(0xFF);
        
        // Try different ranges to cover more ground
        for (uint256 i = 0; i < 10; i++) {
            // Start at a different offset each time
            uint256 startSalt = uint256(keccak256(abi.encodePacked(flags, i))) & type(uint256).max;
            
            // Search 100k possibilities in each range
            for (uint256 j = 0; j < 100_000; j++) {
                uint256 salt = startSalt + j;
                
                bytes32 hash = keccak256(abi.encodePacked(
                    prefix,
                    deployer,
                    bytes32(salt),
                    initCodeHash
                ));
                
                address hookAddress = address(uint160(uint256(hash)));
                uint160 hookFlags = uint160(hookAddress) & HOOK_MASK;
                
                if (hookFlags == flags) {
                    return (hookAddress, bytes32(salt));
                }
            }
        }
        
        revert("HookMiner: could not find salt");
    }
}