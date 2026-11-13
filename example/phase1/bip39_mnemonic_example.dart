// ignore_for_file: avoid_print
import 'package:solana_flutter_sdk/src/crypto/bip39/bip39_mnemonic.dart';

/// Demonstrates BIP-39 mnemonic generation, restoration, and seed
/// derivation, as implemented by [Bip39Mnemonic].
///
/// Covers:
/// - Generating a new 12-word mnemonic (the same default solana-keygen
///   uses).
/// - Generating a mnemonic with a different word count.
/// - Restoring a mnemonic from an existing phrase, with automatic
///   checksum validation.
/// - Deriving the 64-byte BIP-39 seed, with and without a passphrase.
/// - What happens when a phrase or passphrase is invalid.
Future<void> bip39MnemonicExample() async {
  // ---- Generate a new mnemonic ----
  final mnemonic = await Bip39Mnemonic.generate();
  print('Generated 12-word mnemonic:');
  print(mnemonic.phrase);
  print('');

  // ---- Generate with a different word count ----
  final longMnemonic = await Bip39Mnemonic.generate(wordCount: 24);
  print('Generated 24-word mnemonic:');
  print(longMnemonic.phrase);
  print('');

  // ---- Restore a mnemonic from a saved phrase ----
  // This is the official BIP-39 all-zero-entropy test vector; in a
  // real wallet this phrase would come from wherever the user saved
  // it (a paper backup, a secure note, etc).
  const savedPhrase =
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon about';
  final restored = await Bip39Mnemonic.fromPhrase(savedPhrase);
  print('Restored mnemonic from saved phrase:');
  print(restored.phrase);
  print('');

  // ---- Derive the seed, no passphrase ----
  final seed = await restored.toSeed();
  print('Derived seed (no passphrase), ${seed.length} bytes:');
  print(_toHex(seed));
  print('');

  // ---- Derive the seed, with a passphrase ----
  // A different passphrase derives a completely different seed from
  // the exact same mnemonic phrase; this is the standard way to add
  // a "25th word" layer of protection.
  final seedWithPassphrase = await restored.toSeed(passphrase: 'TREZOR');
  print('Derived seed (passphrase "TREZOR"), ${seedWithPassphrase.length} '
      'bytes:');
  print(_toHex(seedWithPassphrase));
  print('');

  // ---- Invalid phrase: unknown word ----
  try {
    await Bip39Mnemonic.fromPhrase(
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon notaword',
    );
  } on ArgumentError catch (e) {
    print('Unknown word rejected as expected: ${e.message}');
  }
  print('');

  // ---- Invalid phrase: bad checksum ----
  try {
    await Bip39Mnemonic.fromPhrase(
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon zoo',
    );
  } on ArgumentError catch (e) {
    print('Bad checksum rejected as expected: ${e.message}');
  }
  print('');

  // ---- Invalid passphrase: non-ASCII ----
  try {
    await restored.toSeed(passphrase: 'café');
  } on ArgumentError catch (e) {
    print('Non-ASCII passphrase rejected as expected: ${e.message}');
  }
}

String _toHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
