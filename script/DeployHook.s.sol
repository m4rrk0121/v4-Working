// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import "../src/SwapHook.sol";
import {HookMiner} from "../test/utils/HookMiner.sol";

interface ICreate2Deployer {
    function safeCreate2(
        bytes32 salt,
        bytes memory initializationCode
    ) external payable returns (address deploymentAddress);
}

contract Deployhook is Script {
    address constant FACTORY = 0x0000000000FFe8B47B3e2130213B802212439497;
    address constant POOL_MANAGER = 0x498581fF718922c3f8e6A244956aF099B2652b2b;

    // Exact flags from v4-core
    uint160 constant BEFORE_SWAP_FLAG = 1 << 7;            // 0x80
    uint160 constant AFTER_SWAP_FLAG = 1 << 6;            // 0x40
    uint160 constant BEFORE_ADD_LIQUIDITY_FLAG = 1 << 11; // 0x800
    uint160 constant BEFORE_REMOVE_LIQUIDITY_FLAG = 1 << 9; // 0x200

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Combine flags exactly as they should be
        uint160 flags = BEFORE_SWAP_FLAG | 
                       AFTER_SWAP_FLAG |
                       BEFORE_ADD_LIQUIDITY_FLAG |
                       BEFORE_REMOVE_LIQUIDITY_FLAG;
        
        console.log("Required flags: %x", flags);
        
        // Get bytecode for the hook
        bytes memory constructorArgs = abi.encode(IPoolManager(POOL_MANAGER));
        bytes memory bytecode = abi.encodePacked(type(SwapHook).creationCode, constructorArgs);
        
        // Generate salt with deployer prefix
        uint256 saltPrefix = uint256(uint160(deployer)) << 96;
        uint256 saltNonce = 40000; // Start from a higher number to get a new address
        address hookAddress;

        // Mine for a hook address with the correct flags
        while (true) {
            bytes32 salt = bytes32(saltPrefix | saltNonce);
            hookAddress = _computeCreate2Address(salt, bytecode);
            if ((uint160(hookAddress) & 0x3FFF) == flags) {
                break;
            }
            saltNonce++;
            require(saltNonce <= type(uint96).max, "Salt overflow");
        }

        bytes32 finalSalt = bytes32(saltPrefix | saltNonce);
        
        console.log("Hook address:", hookAddress);
        console.log("Hook flags:", uint160(hookAddress) & uint160(0x3FFF));
        console.log("Using salt:", vm.toString(finalSalt));
        console.log("Deployer address:", deployer);
        console.log("Iterations:", saltNonce);

        // Deploy with verified salt
        vm.startBroadcast(deployerPrivateKey);
        
        address deployedHook = ICreate2Deployer(FACTORY).safeCreate2{gas: 3000000}(
            finalSalt,
            bytecode
        );
        require(deployedHook == hookAddress, "DeployHook: hook address mismatch");
        
        vm.stopBroadcast();
        
        console.log("Deployed hook at:", deployedHook);
    }

    function _computeCreate2Address(bytes32 salt, bytes memory bytecode) internal pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                FACTORY,
                salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint256(hash)));
    }
}