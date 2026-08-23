[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-teal.svg)](https://opensource.org/licenses/Apache-2.0)
[![Dart](https://img.shields.io/badge/Dart-3.x-teal.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![CI](https://github.com/nemorixgroup/solana-flutter-sdk/actions/workflows/ci.yml/badge.svg)](https://github.com/nemorixgroup/solana-flutter-sdk/actions)
[![Status](https://img.shields.io/badge/Status-Scaffold-lightgrey.svg)](https://github.com/nemorixgroup/solana-flutter-sdk/blob/main)

**English** | [Español](README.es.md)

# solana_flutter_sdk

A native Flutter/Dart SDK for Solana payments.
Pure Dart · No platform channels · Apache 2.0 · pub.dev

> **Status: Repository scaffold.** No implementation yet - Phase 1
> (Cryptographic Fundamentals) starts next.

Built to be an **open, payments-focused Solana SDK**: Solana Pay
(Transfer & Transaction Requests) and Subscriptions & Allowances
(Solana's native recurring-payment primitive), built entirely from
official specs; no dependency on third-party Solana Dart packages.

## Roadmap (v1.0.0)

| Phase | Focus | Version | Status |
|-------|-------|---------|--------|
| 1 | Cryptographic fundamentals (Ed25519) | `0.1.0-dev` | 🔄 In progress |
| 2 | Addresses & encoding (Base58, PDA, ATA) | `0.2.0-dev` | ⏳ Planned |
| 3 | RPC connection layer (HTTP + WebSocket) | `0.3.0-dev` | ⏳ Planned |
| 4 | Transaction construction & signing (legacy + v0) | `0.4.0-dev` | ⏳ Planned |
| 5 | System Program & core token operations | `0.5.0-dev` | ⏳ Planned |
| 6 | Solana Pay: Transfer Request | `0.6.0-dev` | ⏳ Planned |
| 7 | Solana Pay: Transaction Request | `0.7.0-dev` | ⏳ Planned |
| 8 | Subscriptions & Allowances: Delegations | `0.8.0-dev` | ⏳ Planned |
| 9 | Subscriptions & Allowances: Plans | `0.9.0-dev` | ⏳ Planned |
| 10 | Error handling, test suite & v1.0.0 close-out | `1.0.0` | ⏳ Planned |

Deferred to a post-v1.0.0 extended version (documented, not
lost): Token-2022 Confidential extensions, generic Transfer Hook
account resolution, and Address Lookup Table creation/management.

## Documentation & Knowledge Base

This SDK is built on top of the [Solana Knowledge Base](https://github.com/nemorixgroup/Solana-Knowledge-Base), an in-depth guide to the Solana blockchain covering architecture, transactions RPC, Solana Pay, and the development ecosystem. Recommended
reading before diving into the SDK internals.

Every implementation decision behind this SDK - library choices,
encoding standards, verification against official specs - is
documented in [docs-sdk/](https://github.com/nemorixgroup/Solana-Knowledge-Base/tree/main/docs-sdk).


## Installation

```yaml
# pubspec.yaml
dependencies:
  solana_flutter_sdk: ^0.0.1-dev
```

```bash
flutter pub get
```

## Contributing

The SDK is not ready for external contributions yet.
Follow this repository for updates; contributions will
be welcome starting with v1.0.0.

See [CONTRIBUTING.md](CONTRIBUTING.md) for future guidelines.

## License

Licensed under [Apache 2.0](LICENSE).

## For LATAM developers

This SDK is being developed with native support for the region in mind:

- Bilingual documentation (English / Spanish) from the very first module.
- Part of Nemorix Group's SDK ecosystem for financial infrastructure
  in LATAM (Hedera, Avalanche, XRPL).
- Developed by [Nemorix Group](https://nemorixpay.com), Ohio, USA.

Follow us for updates: **sdks@nemorixpay.com**

## Support This Project

If this SDK is useful to you or your team, consider supporting its
development. Every contribution helps cover infrastructure,
documentation, and the time invested in building and maintaining this
open source tool for the Solana and Flutter community. Thank you!

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/nemorixgroupllc)
[![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=github-sponsors&logoColor=white)](https://github.com/sponsors/nemorixgroup)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/nemorixgroupllc)

---

Built by [Nemorix Group](https://nemorixpay.com) · Apache 2.0
