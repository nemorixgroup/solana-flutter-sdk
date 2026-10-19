import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana_flutter_sdk/src/crypto/solana_keypair.dart';

void main() {
  // ---- generate() ----
  group('SolanaKeypair.generate', () {
    test('produces a public key and private key of 32 bytes each', () async {
      final keypair = await SolanaKeypair.generate();

      expect(keypair.publicKey.length, equals(32));
      expect(keypair.privateKey.length, equals(32));
    });

    test('produces a different public key on each call', () async {
      final a = await SolanaKeypair.generate();
      final b = await SolanaKeypair.generate();

      expect(a.publicKey, isNot(equals(b.publicKey)));
    });

    test(
      'public key is internally consistent: independently re-deriving it '
      'from the returned private key seed via Ed25519.newKeyPairFromSeed '
      'produces the same bytes',
      () async {
        final keypair = await SolanaKeypair.generate();

        // Re-derive independently, without going through SolanaKeypair,
        // to confirm generate() did not return a mismatched pair.
        final rederivedKeyPair =
            await Ed25519().newKeyPairFromSeed(keypair.privateKey);
        final rederivedPublicKey = await rederivedKeyPair.extractPublicKey();

        expect(
          Uint8List.fromList(rederivedPublicKey.bytes),
          equals(keypair.publicKey),
        );
      },
    );

    test('toString() never exposes the raw private key', () async {
      final keypair = await SolanaKeypair.generate();
      final text = keypair.toString();

      expect(text, isNot(contains(keypair.privateKey.toString())));
      expect(text, contains('<redacted>'));
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

  // ---- sign() ----
  group('SolanaKeypair.sign', () {
    test('produces a 64-byte signature', () async {
      final keypair = await SolanaKeypair.generate();
      final message = Uint8List.fromList('hello solana'.codeUnits);

      final signature = await keypair.sign(message);

      expect(signature.length, equals(64));
    });

    test('is deterministic: signing the same message twice matches', () async {
      final keypair = await SolanaKeypair.generate();
      final message = Uint8List.fromList('hello solana'.codeUnits);

      final first = await keypair.sign(message);
      final second = await keypair.sign(message);

      expect(first, equals(second));
    });

    test('produces different signatures for different messages', () async {
      final keypair = await SolanaKeypair.generate();
      final messageA = Uint8List.fromList('message A'.codeUnits);
      final messageB = Uint8List.fromList('message B'.codeUnits);

      final signatureA = await keypair.sign(messageA);
      final signatureB = await keypair.sign(messageB);

      expect(signatureA, isNot(equals(signatureB)));
    });

    test(
      'matches RFC 8032 Test 1 (known-answer test, empty message)',
      () async {
        // Same seed as the fromSeed KAT above; RFC 8032 Test 1 also
        // publishes the expected signature for the empty message.
        // Independently cross-checked against Python's `cryptography`
        // library before adding here.
        final seed = _hexToBytes(
          '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
        );
        final expectedSignature = _hexToBytes(
          'e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901'
          '555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a'
          '100b',
        );

        final keypair = await SolanaKeypair.fromSeed(seed);
        final signature = await keypair.sign(Uint8List(0));

        expect(signature, equals(expectedSignature));
      },
    );
  });

  // ---- verifySignature() ----
  group('SolanaKeypair.verifySignature', () {
    test('returns true for a valid signature', () async {
      final keypair = await SolanaKeypair.generate();
      final message = Uint8List.fromList('hello solana'.codeUnits);
      final signature = await keypair.sign(message);

      final isValid = await SolanaKeypair.verifySignature(
        keypair.publicKey,
        message,
        signature,
      );

      expect(isValid, isTrue);
    });

    test('returns false when the message was tampered with', () async {
      final keypair = await SolanaKeypair.generate();
      final signature =
          await keypair.sign(Uint8List.fromList('original'.codeUnits));

      final isValid = await SolanaKeypair.verifySignature(
        keypair.publicKey,
        Uint8List.fromList('tampered'.codeUnits),
        signature,
      );

      expect(isValid, isFalse);
    });

    test('returns false when the signature was tampered with', () async {
      final keypair = await SolanaKeypair.generate();
      final message = Uint8List.fromList('hello solana'.codeUnits);
      final signature = await keypair.sign(message);
      signature[0] = signature[0] ^ 0xFF;

      final isValid = await SolanaKeypair.verifySignature(
        keypair.publicKey,
        message,
        signature,
      );

      expect(isValid, isFalse);
    });

    test('returns false when verified against the wrong public key', () async {
      final signer = await SolanaKeypair.generate();
      final other = await SolanaKeypair.generate();
      final message = Uint8List.fromList('hello solana'.codeUnits);
      final signature = await signer.sign(message);

      final isValid = await SolanaKeypair.verifySignature(
        other.publicKey,
        message,
        signature,
      );

      expect(isValid, isFalse);
    });

    test('throws ArgumentError for a publicKey that is not 32 bytes', () {
      expect(
        () => SolanaKeypair.verifySignature(
          Uint8List(31),
          Uint8List(0),
          Uint8List(64),
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for a signature that is not 64 bytes', () {
      expect(
        () => SolanaKeypair.verifySignature(
          Uint8List(32),
          Uint8List(0),
          Uint8List(63),
        ),
        throwsArgumentError,
      );
    });

    test(
      'matches RFC 8032 Test 1 (known-answer test, empty message)',
      () async {
        final publicKey = _hexToBytes(
          'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
        );
        final signature = _hexToBytes(
          'e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901'
          '555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a'
          '100b',
        );

        final isValid = await SolanaKeypair.verifySignature(
          publicKey,
          Uint8List(0),
          signature,
        );

        expect(isValid, isTrue);
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
