import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana_flutter_sdk/src/crypto/solana_keypair.dart';

void main() {
  group('SolanaKeypair.generate', () {
    test('produces a 32-byte public key and a 32-byte private key seed',
        () async {
      final keypair = await SolanaKeypair.generate();

      expect(keypair.publicKey.length, 32);
      expect(keypair.privateKey.length, 32);
    });

    test('produces distinct keys on each call', () async {
      final a = await SolanaKeypair.generate();
      final b = await SolanaKeypair.generate();

      expect(a.publicKey, isNot(equals(b.publicKey)));
      expect(a.privateKey, isNot(equals(b.privateKey)));
    });

    test('derives a public key consistent with its own private key seed',
        () async {
      // Re-derive the public key from the generated seed using
      // package:cryptography directly, independent of SolanaKeypair,
      // to catch any mismatch between the two key halves.
      final keypair = await SolanaKeypair.generate();
      final reconstructed =
          await Ed25519().newKeyPairFromSeed(keypair.privateKey);
      final reconstructedPublicKey = await reconstructed.extractPublicKey();

      expect(reconstructedPublicKey.bytes, equals(keypair.publicKey));
    });

    test('toString() never includes the raw private key bytes', () async {
      final keypair = await SolanaKeypair.generate();
      final text = keypair.toString();

      expect(text.contains(keypair.privateKey.toString()), isFalse);
      expect(text, contains('redacted'));
    });
  });
}
