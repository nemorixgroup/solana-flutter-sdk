import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// A Solana Ed25519 keypair: a public key and its matching private key.
///
/// Solana identifies every account by a 32-byte Ed25519 public key
/// (see https://solana.com/docs/core/accounts). This class covers
/// keypair *generation* only: producing a brand-new, random keypair
/// using a cryptographically secure random source, via
/// [package:cryptography](https://pub.dev/packages/cryptography)'s
/// [Ed25519] implementation.
///
/// The private key exposed here ([privateKey]) is the raw 32-byte
/// Ed25519 seed, not the 64-byte `secretKey` format used by some
/// Solana tooling (e.g. the Solana CLI's `id.json`, or
/// `@solana/web3.js`'s `Keypair.secretKey`, which concatenates the
/// seed with the public key). Importing/exporting that 64-byte
/// format, and deriving a keypair from an existing seed, is deferred
/// to 0.0.3-dev (`fromSeed` / `fromSecretKey`).
///
/// Usage:
/// ```dart
/// final keypair = await SolanaKeypair.generate();
/// print('Public key length: ${keypair.publicKey.length}'); // 32
/// ```
class SolanaKeypair {
  SolanaKeypair._({
    required this.publicKey,
    required this.privateKey,
  });

  /// The 32-byte Ed25519 public key.
  ///
  /// This is the raw form of what becomes the Solana account address
  /// once Base58-encoded (added in Phase 2, Addresses & Encoding).
  final Uint8List publicKey;

  /// The 32-byte Ed25519 private key seed.
  ///
  /// Treat as sensitive: never log, print, or transmit this value.
  /// [toString] deliberately omits it.
  final Uint8List privateKey;

  /// The Ed25519 algorithm instance used for all keypair operations.
  static final Ed25519 _algorithm = Ed25519();

  /// Generates a new, random Ed25519 keypair.
  ///
  /// Each call produces a different keypair, drawn from a
  /// cryptographically secure random source supplied by
  /// `package:cryptography`.
  static Future<SolanaKeypair> generate() async {
    // Ask package:cryptography for a fresh random Ed25519 keypair.
    final keyPair = await _algorithm.newKeyPair();

    // Extract the public key half (32 bytes).
    final publicKey = await keyPair.extractPublicKey();

    // Extract the private key half: the 32-byte seed.
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();

    return SolanaKeypair._(
      publicKey: Uint8List.fromList(publicKey.bytes),
      privateKey: Uint8List.fromList(privateKeyBytes),
    );
  }

  /// Deliberately omits [privateKey] to avoid accidental leaks via
  /// logging, debugging, or error messages.
  @override
  String toString() => 'SolanaKeypair(publicKey: ${publicKey.length} bytes, '
      'privateKey: <redacted>)';
}
