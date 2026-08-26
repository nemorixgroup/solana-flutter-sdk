// example/phase1/keypair_generation_example.dart
//
// Phase 1 - Cryptographic Fundamentals
// https://github.com/nemorixgroup/Solana-Knowledge-Base/tree/main/docs-sdk/phase-1

import 'package:solana_flutter_sdk/solana_flutter_sdk.dart';

/// Demonstrates generating a new, random Ed25519 keypair.
Future<void> keypairGenerationExample() async {
  final keypair = await SolanaKeypair.generate();

  print('Public key (${keypair.publicKey.length} bytes): '
      '${keypair.publicKey}');

  // Never print or log a real private key. We only show its length
  // here, the same restraint SolanaKeypair.toString() enforces.
  print('Private key seed (${keypair.privateKey.length} bytes): '
      '<redacted>');

  // Calling generate() again always produces a different keypair.
  final another = await SolanaKeypair.generate();
  final areDifferent =
      keypair.publicKey.toString() != another.publicKey.toString();
  print('Second call produces a different public key: $areDifferent');
}
