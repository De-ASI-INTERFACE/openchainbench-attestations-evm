// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IOpenChainBenchAttestations.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract OpenChainBenchAttestations is IOpenChainBenchAttestations, AccessControl {
    bytes32 public constant HARNESS_SIGNER_ROLE = keccak256("HARNESS_SIGNER_ROLE");
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    uint64 public maxValiditySecs;
    uint8 public specVersion;

    mapping(bytes32 attestationId => Attestation) private _attestations;
    mapping(bytes32 key => ProviderProfile) private _profiles;

    constructor(address admin, uint64 _maxValiditySecs, uint8 _specVersion) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(HARNESS_SIGNER_ROLE, admin);
        _grantRole(UPDATER_ROLE, admin);
        maxValiditySecs = _maxValiditySecs;
        specVersion = _specVersion;
    }

    function createAttestation(
        bytes32 attestationId,
        bytes32 benchmarkRunHash,
        bytes32 kpiAggregateHash,
        uint64 validFrom,
        uint64 validUntil,
        uint8 category,
        uint8 _specVersion
    ) external override {
        require(hasRole(HARNESS_SIGNER_ROLE, msg.sender), "Not harness signer");
        require(validUntil > validFrom, "Invalid window");
        require(validUntil - validFrom <= maxValiditySecs, "Window too long");

        Attestation storage a = _attestations[attestationId];
        require(a.harnessSigner == address(0), "Already exists");

        a.benchmarkRunHash = benchmarkRunHash;
        a.kpiAggregateHash = kpiAggregateHash;
        a.validFrom = validFrom;
        a.validUntil = validUntil;
        a.harnessSigner = msg.sender;
        a.category = category;
        a.specVersion = _specVersion;
        a.revoked = false;

        emit AttestationCreated(attestationId, msg.sender, benchmarkRunHash, category, validFrom, validUntil);
    }

    function revokeAttestation(bytes32 attestationId) external override {
        Attestation storage a = _attestations[attestationId];
        require(a.harnessSigner != address(0), "Unknown");
        require(!a.revoked, "Already revoked");
        require(
            msg.sender == a.harnessSigner || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Unauthorized"
        );

        a.revoked = true;
        emit AttestationRevoked(attestationId);
    }

    function updateProviderProfile(
        bytes32 providerId,
        uint256 chainId,
        bytes32 regionHash,
        bytes32 attestationHash,
        uint96 rollingP99,
        uint96 rollingSuccessRatio
    ) external override {
        require(hasRole(UPDATER_ROLE, msg.sender), "Not updater");

        bytes32 key = keccak256(abi.encodePacked(providerId, chainId, regionHash));
        ProviderProfile storage p = _profiles[key];

        if (p.lastUpdatedBlock == 0) {
            p.lastAttestations = new bytes32[](0);
        }

        if (p.lastAttestations.length >= 10) {
            bytes32[] memory arr = p.lastAttestations;
            bytes32[] memory next = new bytes32[](arr.length);
            for (uint256 i = 1; i < arr.length; i++) {
                next[i - 1] = arr[i];
            }
            p.lastAttestations = next;
        }

        bytes32[] memory arr2 = new bytes32[](p.lastAttestations.length + 1);
        for (uint256 i = 0; i < p.lastAttestations.length; i++) {
            arr2[i] = p.lastAttestations[i];
        }
        arr2[arr2.length - 1] = attestationHash;
        p.lastAttestations = arr2;

        p.rollingP99 = rollingP99;
        p.rollingSuccessRatio = rollingSuccessRatio;
        p.lastUpdatedBlock = uint64(block.number);

        emit ProviderProfileUpdated(providerId, chainId, regionHash);
    }

    function getAttestation(bytes32 attestationId) external view override returns (Attestation memory) {
        return _attestations[attestationId];
    }

    function getProviderProfile(
        bytes32 providerId,
        uint256 chainId,
        bytes32 regionHash
    ) external view override returns (ProviderProfile memory) {
        bytes32 key = keccak256(abi.encodePacked(providerId, chainId, regionHash));
        return _profiles[key];
    }

    function setMaxValiditySecs(uint64 _v) external onlyRole(DEFAULT_ADMIN_ROLE) {
        maxValiditySecs = _v;
    }

    function setSpecVersion(uint8 _v) external onlyRole(DEFAULT_ADMIN_ROLE) {
        specVersion = _v;
    }
}
