import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// A Solana Ed25519 keypair: a public key and its matching private key.
///
/// Solana identifies every account by a 32-byte Ed25519 public key
/// (see https://solana.com/docs/core/accounts). This class covers
/// keypair generation and import, using
/// [package:cryptography](https://pub.dev/packages/cryptography)'s
/// [Ed25519] implementation for every operation.
///
/// The private key exposed here ([privateKey]) is always the raw 32-byte
/// Ed25519 seed, not the 64-byte `secretKey` format used by some
/// Solana tooling (e.g. the Solana CLI's `id.json`, or
/// `@solana/web3.js`'s `Keypair.secretKey`, which concatenates the
/// seed with the public key). [fromSecretKey] accepts that 64-byte
/// format on import but still stores/exposes only the 32-byte seed.
///
/// Usage:
/// ```dart
/// // Generate a brand-new random keypair.
/// final keypair = await SolanaKeypair.generate();
///
/// // Recreate a keypair from a known 32-byte seed.
/// final restored = await SolanaKeypair.fromSeed(seed);
///
/// // Import a keypair from a Solana CLI id.json (64-byte secretKey).
/// final imported = await SolanaKeypair.fromSecretKey(secretKeyBytes);
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

  /// The exact byte length of a raw Ed25519 seed/private key.
  static const int _seedLength = 32;

  /// The exact byte length of Solana's concatenated `secretKey` format
  /// (32-byte seed + 32-byte public key).
  static const int _secretKeyLength = 64;

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

  /// Deterministically recreates a keypair from a 32-byte Ed25519 seed.
  ///
  /// The same [seed] always produces the same keypair, so this is how
  /// a previously generated keypair is restored (e.g. from secure
  /// storage) without keeping the public key around separately.
  ///
  /// Throws [ArgumentError] if [seed] is not exactly 32 bytes.
  static Future<SolanaKeypair> fromSeed(Uint8List seed) async {
    // Validate length upfront so the error clearly names the problem,
    // instead of surfacing as an opaque failure from the algorithm.
    if (seed.length != _seedLength) {
      throw ArgumentError.value(
        seed.length,
        'seed.length',
        'Ed25519 seed must be exactly $_seedLength bytes',
      );
    }

    // Derive the key pair deterministically from the seed.
    final keyPair = await _algorithm.newKeyPairFromSeed(seed);
    final publicKey = await keyPair.extractPublicKey();

    return SolanaKeypair._(
      publicKey: Uint8List.fromList(publicKey.bytes),
      privateKey: Uint8List.fromList(seed),
    );
  }

  /// Imports a keypair from Solana's 64-byte `secretKey` format:
  /// a 32-byte seed followed by its 32-byte public key, concatenated.
  ///
  /// This is the format used by the Solana CLI's `id.json` keypair
  /// files (`solana-keygen`) and by `@solana/web3.js`'s
  /// `Keypair.secretKey`, so it is the natural entry point for
  /// importing keys generated outside this SDK.
  ///
  /// The embedded public key (bytes 32-63) is cross-checked against
  /// the public key derived from the embedded seed (bytes 0-31), to
  /// catch a corrupted or hand-edited `secretKey` early rather than
  /// silently producing a keypair with a mismatched address.
  ///
  /// Throws [ArgumentError] if [secretKey] is not exactly 64 bytes,
  /// or if the embedded public key does not match the one derived
  /// from the embedded seed.
  static Future<SolanaKeypair> fromSecretKey(Uint8List secretKey) async {
    if (secretKey.length != _secretKeyLength) {
      throw ArgumentError.value(
        secretKey.length,
        'secretKey.length',
        'Solana secretKey must be exactly $_secretKeyLength bytes '
            '($_seedLength-byte seed + $_seedLength-byte public key)',
      );
    }

    // Split the 64 bytes into its two halves.
    final seed = Uint8List.sublistView(secretKey, 0, _seedLength);
    final embeddedPublicKey =
        Uint8List.sublistView(secretKey, _seedLength, _secretKeyLength);

    // Re-derive the keypair from the seed half alone.
    final keypair = await fromSeed(Uint8List.fromList(seed));

    // Confirm the embedded public key matches what the seed derives,
    // so a mismatched/corrupted secretKey fails loudly on import.
    if (!_bytesEqual(keypair.publicKey, embeddedPublicKey)) {
      throw ArgumentError(
        'secretKey is invalid: the embedded public key does not match '
        'the public key derived from the embedded seed',
      );
    }

    return keypair;
  }

  /// Compares two byte lists for equality.
  ///
  /// Public keys are not sensitive, so a plain (non constant-time)
  /// comparison is sufficient here; only [privateKey]/seed material
  /// needs that extra care, and this method never touches it.
  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Deliberately omits [privateKey] to avoid accidental leaks via
  /// logging, debugging, or error messages.
  @override
  String toString() => 'SolanaKeypair(publicKey: ${publicKey.length} bytes, '
      'privateKey: <redacted>)';
}
