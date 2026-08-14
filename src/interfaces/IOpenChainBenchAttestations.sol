// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

struct Attestation {
    bytes32 benchmarkRunHash;
    bytes32 kpiAggregateHash;
    uint64 validFrom;
    uint64 validUntil;
    address harnessSigner;
    uint8 category; // 0=rpc,1=intents,2=aa
    uint8 specVersion;
    bool revoked;
}

struct ProviderProfile {
    bytes32[] lastAttestations;
    uint96 rollingP99;
    uint96 rollingSuccessRatio;
    uint64 lastUpdatedBlock;
}

interface IOpenChainBenchAttestations {
    function createAttestation(
        bytes32 attestationId,
        bytes32 benchmarkRunHash,
        bytes32 kpiAggregateHash,
        uint64 validFrom,
        uint64 validUntil,
        uint8 category,
        uint8 specVersion
    ) external;

    function revokeAttestation(bytes32 attestationId) external;

    function updateProviderProfile(
        bytes32 providerId,
        uint256 chainId,
        bytes32 regionHash,
        bytes32 attestationHash,
        uint96 rollingP99,
        uint96 rollingSuccessRatio
    ) external;

    function getAttestation(bytes32 attestationId) external view returns (Attestation memory);

    function getProviderProfile(
        bytes32 providerId,
        uint256 chainId,
        bytes32 regionHash
    ) external view returns (ProviderProfile memory);

    event AttestationCreated(
        bytes32 attestationId,
        address harnessSigner,
        bytes32 benchmarkRunHash,
        uint8 category,
        uint64 validFrom,
        uint64 validUntil
    );

    event AttestationRevoked(bytes32 attestationId);

    event ProviderProfileUpdated(
        bytes32 providerId,
        uint256 chainId,
        bytes32 regionHash
    );
}
