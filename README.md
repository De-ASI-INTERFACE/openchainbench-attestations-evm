# OpenChainBench Attestations (EVM/Solidity)

On-chain performance attestation contract for OpenChainBench KPIs on EVM chains.

## Architecture

- `src/OpenChainBenchAttestations.sol` – Core contract with:
  - `Attestation` and `ProviderProfile` structs
  - `createAttestation`, `revokeAttestation`, `updateProviderProfile`
  - Access control for harness signers, updaters, and admin
- `src/interfaces/IOpenChainBenchAttestations.sol` – Public interface
- `test/` – Foundry tests covering creation, revocation, profile updates, validity windows, and access control
- `script/` – Foundry deploy script

## Data model

- Attestations bind a harness signer to a `benchmarkRunHash` and `kpiAggregateHash` with a time-bound validity window.
- Provider profiles maintain rolling attestation references and aggregate KPIs (p99, success ratio).
- All raw samples remain off-chain; only hashes and aggregates are stored on-chain.

## Safety

- No secrets or credentials on-chain
- Time-bound validity windows; revocation supported
- Access control via roles (harness signers, updaters, admin multi-sig)

## Deployment

```bash
forge install
forge build
forge script script/Deploy.s.sol --rpc-url <URL> --broadcast
```

## Integration example

```solidity
IOpenChainBenchAttestations att = IOpenChainBenchAttestations(0x...);
Attestation a = att.getAttestation(attestationId);
require(!a.revoked && block.timestamp >= a.validFrom && block.timestamp <= a.validUntil, "Invalid attestation");
```

## License

MIT
