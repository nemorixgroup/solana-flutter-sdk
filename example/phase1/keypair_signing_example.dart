import 'dart:typed_data';

import 'package:solana_flutter_sdk/src/crypto/solana_keypair.dart';

/// Demonstrates signing a message with a [SolanaKeypair] and verifying
/// that signature using only the signer's public key.
///
/// Covers the two entry points added on top of `generate()`,
/// `fromSeed()`, and `fromSecretKey()`:
/// - [SolanaKeypair.sign]: signs arbitrary bytes with this keypair's
///   private key.
/// - [SolanaKeypair.verifySignature]: a static method, since
///   verifying a signature never needs a private key, only the
///   signer's public key.
Future<void> keypairSigningExample() async {
  final keypair = await SolanaKeypair.generate();
  final message = Uint8List.fromList('Hello, Solana!'.codeUnits);

  // ---- Signing ----
  final signature = await keypair.sign(message);
  print('Signature length: ${signature.length} bytes');

  // ---- Verifying with the correct public key ----
  final isValid = await SolanaKeypair.verifySignature(
    keypair.publicKey,
    message,
    signature,
  );
  print('Signature valid for the original message: $isValid');

  // ---- Verifying fails if the message was tampered with ----
  final tamperedMessage = Uint8List.fromList('Hello, Solana?'.codeUnits);
  final isValidForTampered = await SolanaKeypair.verifySignature(
    keypair.publicKey,
    tamperedMessage,
    signature,
  );
  print('Signature valid for a tampered message: $isValidForTampered');

  // ---- Verifying fails against the wrong public key ----
  final other = await SolanaKeypair.generate();
  final isValidForWrongKey = await SolanaKeypair.verifySignature(
    other.publicKey,
    message,
    signature,
  );
  print('Signature valid for a different public key: $isValidForWrongKey');

  // ---- Rejecting invalid input ----
  try {
    await SolanaKeypair.verifySignature(
      Uint8List(16),
      message,
      signature,
    );
  } on ArgumentError catch (e) {
    print('Rejected short public key as expected: ${e.message}');
  }
}
