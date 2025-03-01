// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

contract VerifyHook is Script {
    function run() public {
        string[] memory inputs = new string[](14);
        inputs[0] = "forge"; 
        inputs[1] = "verify-contract";
        inputs[2] = "0xdca7a1DC2eaDB34387630D2353E30f6cc0398AC0";  // Your actual deployed address
        inputs[3] = "src/SwapHook.sol:SwapHook";
        inputs[4] = "--verifier-url";
        inputs[5] = "https://api.basescan.org/api";
        inputs[6] = "--etherscan-api-key";
        inputs[7] = vm.envString("BASE_API_KEY");
        inputs[8] = "--constructor-args";
        inputs[9] = "0x000000000000000000000000498581ff718922c3f8e6a244956af099b2652b2b";
        inputs[10] = "--compiler-version";
        inputs[11] = "v0.8.26";
        inputs[12] = "--num-of-optimizations";
        inputs[13] = "200";

        vm.ffi(inputs);
    }
} 