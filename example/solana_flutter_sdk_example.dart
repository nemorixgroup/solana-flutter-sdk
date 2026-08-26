// solana_flutter_sdk - Quick Start Examples
//
// This file is the entry point for all SDK examples. Each phase's
// examples live in their own file under example/phaseN/, one file
// per sub-version released within that phase.
//
// Technical decisions behind every example (why a library was chosen,
// how it was verified against official sources) are documented at:
// https://github.com/nemorixgroup/Solana-Knowledge-Base/tree/main/docs-sdk
//
// Running this example:
// ```sh
// dart run example/solana_flutter_sdk_example.dart
// ```
// GitHub:
// https://github.com/nemorixgroup/solana-flutter-sdk/blob/main/example/solana_flutter_sdk_example.dart
//
// Planned phases:
//   Phase 1 - Cryptographic Fundamentals (Ed25519) - CURRENT
//   Phase 2 - Addresses & encoding (Base58, PDA, ATA)
//   Phase 3 - RPC connection layer (HTTP + WebSocket)
//   Phase 4 - Transaction construction & signing (legacy + v0)
//   Phase 5 - System Program & core token operations
//   Phase 6 - Solana Pay: Transfer Request
//   Phase 7 - Solana Pay: Transaction Request
//   Phase 8 - Subscriptions & Allowances: Delegations
//   Phase 9 - Subscriptions & Allowances: Plans
//   Phase 10 - Error handling, test suite & v1.0.0 close-out

import 'phase1/keypair_generation_example.dart';

Future<void> main() async {
  print('--- 0.0.1-dev: Initial repository scaffold ---');

  print('\n--- 0.0.2-dev: Keypair generation ---');
  await keypairGenerationExample();
}
