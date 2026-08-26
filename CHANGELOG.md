# Changelog

## 0.0.2-dev

Phase 1 in progress: Ed25519 keypair generation, the first
implementation on top of the 0.0.1-dev scaffold.

### Added

- `SolanaKeypair`: wraps a Solana Ed25519 keypair (32-byte public
  key, 32-byte private key seed)
- `SolanaKeypair.generate()`: generates a new, random Ed25519 keypair
  via `package:cryptography`'s `Ed25519` implementation
- 4 new unit tests (1 -> 5): key length, uniqueness across calls,
  internal public/private key consistency (re-derived independently
  via `Ed25519.newKeyPairFromSeed`), and that `toString()` never
  exposes the raw private key
- `example/phase1/keypair_generation_example.dart`: demonstrates
  `SolanaKeypair.generate()` usage, wired into the main example entry
  point

### Design Decisions

- `SolanaKeypair.privateKey` is the raw 32-byte Ed25519 seed, not the
  64-byte `secretKey` format used by some Solana tooling (Solana
  CLI's `id.json`, `@solana/web3.js`'s `Keypair.secretKey`), which
  concatenates the seed with the public key - confirmed against the
  official `solana-web3.js` `Keypair` docs before implementing.
  Supporting that 64-byte format is deferred to `fromSecretKey` in
  0.0.3-dev
- No RFC 8032 known-answer test vector included yet: `generate()`
  produces random output, so there's no fixed expected result to
  verify against. Independent (Python/PyNaCl) test-vector
  verification is deferred to 0.0.3-dev, once `fromSeed` makes
  deterministic output possible

### Status

Phase 1 in progress: random keypair generation complete and tested.
No seed import/export, signing, or verification yet.  
Not ready for production use.  
Next: `fromSeed` / `fromSecretKey` (`0.0.3-dev`).

## 0.0.1-dev

- Initial repository scaffold: pubspec, CI, lint config, license.
- Reserves the `solana_flutter_sdk` name on pub.dev.
- No implementation yet - Phase 1 (Cryptographic Fundamentals)
  starts next.
