import 'dart:typed_data';
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

  // ---- fromSeed() ----
  group('SolanaKeypair.fromSeed', () {
    test('recreates the same keypair from the same seed', () async {
      final original = await SolanaKeypair.generate();

      final restored = await SolanaKeypair.fromSeed(original.privateKey);

      expect(restored.privateKey, equals(original.privateKey));
      expect(restored.publicKey, equals(original.publicKey));
    });

    test('different seeds produce different keypairs', () async {
      final a = await SolanaKeypair.generate();
      final b = await SolanaKeypair.generate();

      final restoredA = await SolanaKeypair.fromSeed(a.privateKey);

      expect(restoredA.publicKey, isNot(equals(b.publicKey)));
    });

    test('throws ArgumentError for a seed shorter than 32 bytes', () {
      final shortSeed = Uint8List(31);

      expect(
        () => SolanaKeypair.fromSeed(shortSeed),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for a seed longer than 32 bytes', () {
      final longSeed = Uint8List(33);

      expect(
        () => SolanaKeypair.fromSeed(longSeed),
        throwsArgumentError,
      );
    });

    test(
      'derives the correct public key for RFC 8032 Test 1 (known-answer '
      'test)',
      () async {
        // RFC 8032 Section 7.1, TEST 1:
        // https://www.rfc-editor.org/rfc/rfc8032#section-7.1
        // Independently cross-checked against Python's `cryptography`
        // library (OpenSSL-backed Ed25519) before adding here.
        final seed = _hexToBytes(
          '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
        );
        final expectedPublicKey = _hexToBytes(
          'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
        );

        final keypair = await SolanaKeypair.fromSeed(seed);

        expect(keypair.publicKey, equals(expectedPublicKey));
      },
    );
  });

  // ---- fromSecretKey() ----
  group('SolanaKeypair.fromSecretKey', () {
    test('imports a valid 64-byte secretKey (seed + public key)', () async {
      final original = await SolanaKeypair.generate();
      final secretKey = Uint8List(64)
        ..setRange(0, 32, original.privateKey)
        ..setRange(32, 64, original.publicKey);

      final imported = await SolanaKeypair.fromSecretKey(secretKey);

      expect(imported.privateKey, equals(original.privateKey));
      expect(imported.publicKey, equals(original.publicKey));
    });

    test('throws ArgumentError for a secretKey that is not 64 bytes', () {
      final wrongLength = Uint8List(63);

      expect(
        () => SolanaKeypair.fromSecretKey(wrongLength),
        throwsArgumentError,
      );
    });

    test(
      'throws ArgumentError when the embedded public key does not match '
      'the seed',
      () async {
        final a = await SolanaKeypair.generate();
        final b = await SolanaKeypair.generate();

        // Seed from `a` paired with the public key from `b`: corrupted.
        final tamperedSecretKey = Uint8List(64)
          ..setRange(0, 32, a.privateKey)
          ..setRange(32, 64, b.publicKey);

        expect(
          () => SolanaKeypair.fromSecretKey(tamperedSecretKey),
          throwsArgumentError,
        );
      },
    );
  });
}

/// Decodes a hex string (no `0x` prefix, no separators) into bytes.
Uint8List _hexToBytes(String hex) {
  final result = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}
