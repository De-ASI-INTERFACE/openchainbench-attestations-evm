// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/OpenChainBenchAttestations.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployer = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        uint64 maxValiditySecs = uint64(vm.envOr("MAX_VALIDITY_SECS", int256(30 * 24 * 60 * 60)));
        uint8 specVersion = uint8(vm.envOr("SPEC_VERSION", int256(1)));

        vm.startBroadcast(deployer);
        OpenChainBenchAttestations att = new OpenChainBenchAttestations(admin, maxValiditySecs, specVersion);
        vm.stopBroadcast();

        console.log("Deployed OpenChainBenchAttestations at:", address(att));
    }
}
