import 'dart:typed_data';

import 'package:solana_flutter_sdk/src/crypto/solana_keypair.dart';

/// Demonstrates importing a [SolanaKeypair] from previously known key
/// material, instead of generating a brand-new random one.
///
/// Covers the two entry points added alongside `generate()`:
/// - [SolanaKeypair.fromSeed]: a raw 32-byte Ed25519 seed.
/// - [SolanaKeypair.fromSecretKey]: Solana's 64-byte `secretKey` format
///   (seed + public key), the same format found in a Solana CLI
///   `id.json` file or returned by `@solana/web3.js`'s
///   `Keypair.secretKey`.
Future<void> keypairImportExample() async {
  // ---- Restoring a keypair from a seed ----
  // In a real app, this seed would come from secure storage rather
  // than a fresh generate() call.
  final original = await SolanaKeypair.generate();
  print('Original public key length: ${original.publicKey.length} bytes');

  final restored = await SolanaKeypair.fromSeed(original.privateKey);
  print('Restored public key matches original: '
      '${_bytesEqual(restored.publicKey, original.publicKey)}');

  // ---- Importing a keypair from a 64-byte secretKey ----
  // This is the shape of the numbers array found in a Solana CLI
  // id.json file, or Keypair.secretKey in @solana/web3.js.
  final secretKey = Uint8List(64)
    ..setRange(0, 32, original.privateKey)
    ..setRange(32, 64, original.publicKey);

  final imported = await SolanaKeypair.fromSecretKey(secretKey);
  print('Imported public key matches original: '
      '${_bytesEqual(imported.publicKey, original.publicKey)}');

  // ---- Rejecting invalid input ----
  // A wrong-length seed, or a secretKey whose embedded public key
  // does not match its embedded seed, fails loudly instead of
  // silently producing the wrong keypair.
  try {
    await SolanaKeypair.fromSeed(Uint8List(16));
  } on ArgumentError catch (e) {
    print('Rejected short seed as expected: ${e.message}');
  }
}

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
