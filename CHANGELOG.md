# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.0.4-dev

Phase 1 in progress: message signing and verification via `sign` and
`verifySignature`, completing the core Ed25519 primitives on top of
`0.0.3-dev`'s keypair import.

### Added

- `SolanaKeypair.sign(Uint8List message)`: signs arbitrary bytes with
  this keypair's private key, returning a 64-byte Ed25519 signature
- `SolanaKeypair.verifySignature(Uint8List publicKey, Uint8List message,
  Uint8List signature)`: static method, verifies a signature against
  a public key alone, with no `SolanaKeypair` instance (and no
  private key) required
- 11 new unit tests (13 -> 24): signature length, determinism,
  different messages producing different signatures, an RFC 8032
  Test 1 known-answer test for both `sign` and `verifySignature`,
  tampered-message/tampered-signature/wrong-public-key rejection, and
  length validation for `publicKey`/`signature`
- `example/phase1/keypair_signing_example.dart`: demonstrates `sign`
  and `verifySignature`, including the tampered-message,
  wrong-public-key, and invalid-input cases, wired into the main
  example entry point

### Design Decisions

- `verifySignature` is a static method rather than an instance
  method: verifying a signature only ever needs the signer's public
  key, never a private key, and the common case is verifying someone
  else's signature with no `SolanaKeypair` instance for it in the
  first place
- Both `publicKey` (32 bytes) and `signature` (64 bytes) are
  length-validated upfront with `ArgumentError`, matching the pattern
  already used in `fromSeed`/`fromSecretKey`
- Extends the RFC 8032 Test 1 known-answer test from `0.0.3-dev`: the
  same official vector also publishes the expected signature for the
  empty message, so `sign` and `verifySignature` are both checked
  against it, independently cross-checked with Python's
  `cryptography` library before being added to the suite

### Status

Phase 1 in progress: keypair generation, import, and
signing/verification complete and tested, including RFC 8032
known-answer vectors for seed-to-public-key derivation and for
signing.  
No mnemonic or hierarchical derivation support yet.  
Not ready for production use.  
Next: BIP39 mnemonic support (`0.0.5-dev`).  

## 0.0.3-dev

Phase 1 in progress: keypair import via `fromSeed` and `fromSecretKey`,
completing deterministic keypair reconstruction on top of `0.0.2-dev`'s
random generation.

### Added

- `SolanaKeypair.fromSeed(Uint8List seed)`: deterministically recreates
  a keypair from a 32-byte Ed25519 seed
- `SolanaKeypair.fromSecretKey(Uint8List secretKey)`: imports a keypair
  from Solana's 64-byte `secretKey` format (32-byte seed + 32-byte
  public key), the format used by the Solana CLI's `id.json` and
  `@solana/web3.js`'s `Keypair.secretKey`
- 8 new unit tests (5 -> 13): `fromSeed` determinism, seed-length
  validation (short/long), an RFC 8032 Test 1 known-answer test,
  `fromSecretKey` round-trip import, secretKey-length validation, and
  rejection of a secretKey whose embedded public key does not match
  its embedded seed
- `example/phase1/keypair_import_example.dart`: demonstrates restoring
  a keypair via `fromSeed` and importing one via `fromSecretKey`, wired
  into the main example entry point

### Design Decisions

- `fromSecretKey` cross-checks the embedded public key (bytes 32-63)
  against the public key re-derived from the embedded seed (bytes
  0-31), so a corrupted or hand-edited secretKey fails loudly on
  import instead of silently producing a keypair with a mismatched
  address
- Length validation happens upfront with `ArgumentError`, naming the
  expected byte length, rather than relying on an opaque failure from
  `package:cryptography`
- Closes the RFC 8032 known-answer test deferred in `0.0.2-dev`:
  `fromSeed` is tested against official Test 1 from RFC 8032 Section
  7.1 (seed -> public key), independently cross-checked against
  Python's `cryptography` library (OpenSSL-backed Ed25519) before
  being added to the suite

### Status

Phase 1 in progress: keypair generation and import (seed and
secretKey) complete and tested, including one RFC 8032 known-answer
vector.  
No signing, verification, mnemonic, or derivation support yet.
Not ready for production use.  
Next: `sign` / `verify` (`0.0.4-dev`).

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
