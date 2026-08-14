// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/OpenChainBenchAttestations.sol";

contract OpenChainBenchAttestationsTest is Test {
    OpenChainBenchAttestations att;
    address admin = address(1);
    address harness = address(2);
    address updater = address(3);
    address other = address(4);

    bytes32 constant RUN_HASH = keccak256("run");
    bytes32 constant KPI_HASH = keccak256("kpi");

    function setUp() public {
        att = new OpenChainBenchAttestations(admin, 30 * 24 * 60 * 60, 1);
        att.grantRole(att.HARNESS_SIGNER_ROLE(), harness);
        att.grantRole(att.UPDATER_ROLE(), updater);
    }

    function testCreateAttestation() public {
        bytes32 attId = keccak256("att1");
        uint64 validFrom = uint64(block.timestamp);
        uint64 validUntil = validFrom + 24 * 60 * 60;

        vm.prank(harness);
        att.createAttestation(attId, RUN_HASH, KPI_HASH, validFrom, validUntil, 0, 1);

        Attestation a = att.getAttestation(attId);
        assertEq(a.benchmarkRunHash, RUN_HASH);
        assertEq(a.kpiAggregateHash, KPI_HASH);
        assertEq(a.validFrom, validFrom);
        assertEq(a.validUntil, validUntil);
        assertEq(a.harnessSigner, harness);
        assertEq(a.category, 0);
        assertEq(a.specVersion, 1);
        assertEq(a.revoked, false);
    }

    function testRevokeAttestation() public {
        bytes32 attId = keccak256("att2");
        uint64 validFrom = uint64(block.timestamp);
        uint64 validUntil = validFrom + 24 * 60 * 60;

        vm.prank(harness);
        att.createAttestation(attId, RUN_HASH, KPI_HASH, validFrom, validUntil, 0, 1);

        vm.prank(harness);
        att.revokeAttestation(attId);

        Attestation a = att.getAttestation(attId);
        assertEq(a.revoked, true);
    }

    function testRevokeUnauthorized() public {
        bytes32 attId = keccak256("att3");
        uint64 validFrom = uint64(block.timestamp);
        uint64 validUntil = validFrom + 24 * 60 * 60;

        vm.prank(harness);
        att.createAttestation(attId, RUN_HASH, KPI_HASH, validFrom, validUntil, 0, 1);

        vm.prank(other);
        vm.expectRevert();
        att.revokeAttestation(attId);
    }

    function testUpdateProviderProfile() public {
        bytes32 providerId = keccak256("provider");
        uint256 chainId = 8453;
        bytes32 regionHash = keccak256("us-east-1");
        bytes32 attHash = keccak256("att");
        uint96 p99 = 120;
        uint96 sr = 999_000;

        vm.prank(updater);
        att.updateProviderProfile(providerId, chainId, regionHash, attHash, p99, sr);

        ProviderProfile p = att.getProviderProfile(providerId, chainId, regionHash);
        assertEq(p.lastAttestations.length, 1);
        assertEq(p.lastAttestations[0], attHash);
        assertEq(p.rollingP99, p99);
        assertEq(p.rollingSuccessRatio, sr);
        assertEq(p.lastUpdatedBlock, block.number);
    }

    function testValidityWindowTooLong() public {
        bytes32 attId = keccak256("att4");
        uint64 validFrom = uint64(block.timestamp);
        uint64 validUntil = validFrom + uint64(att.maxValiditySecs()) + 1;

        vm.prank(harness);
        vm.expectRevert();
        att.createAttestation(attId, RUN_HASH, KPI_HASH, validFrom, validUntil, 0, 1);
    }

    function testCreateAttestationUnauthorized() public {
        bytes32 attId = keccak256("att5");
        uint64 validFrom = uint64(block.timestamp);
        uint64 validUntil = validFrom + 24 * 60 * 60;

        vm.prank(other);
        vm.expectRevert();
        att.createAttestation(attId, RUN_HASH, KPI_HASH, validFrom, validUntil, 0, 1);
    }
}
