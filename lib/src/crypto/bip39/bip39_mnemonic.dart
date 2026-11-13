import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:solana_flutter_sdk/src/crypto/bip39/bip39_wordlist.dart';

/// A BIP-39 mnemonic phrase: a human-readable backup of random entropy,
/// used to deterministically back up and restore a wallet's keys.
///
/// This class covers generating a new mnemonic, restoring/validating
/// an existing one, and deriving the 64-byte seed the BIP-39 spec
/// defines (https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).
/// Turning that seed into an actual `SolanaKeypair` requires SLIP-0010
/// hierarchical derivation, which is a separate, later step, not
/// covered here.
///
/// Only the official BIP-39 English wordlist is supported.
///
/// Usage:
/// ```dart
/// // Generate a new 12-word mnemonic (the same default as solana-keygen).
/// final mnemonic = await Bip39Mnemonic.generate();
/// print(mnemonic.phrase);
///
/// // Restore one from an existing phrase; the checksum is verified
/// // automatically, so a mistyped phrase throws instead of silently
/// // producing the wrong seed.
/// final restored = await Bip39Mnemonic.fromPhrase(savedPhrase);
///
/// // Derive the 64-byte BIP-39 seed (no passphrase).
/// final seed = await restored.toSeed();
/// ```
class Bip39Mnemonic {
  Bip39Mnemonic._(this.phrase, this.words);

  /// The mnemonic phrase, as space-separated words.
  final String phrase;

  /// The individual words making up [phrase], in order.
  final List<String> words;

  /// The word counts BIP-39 allows, matching what `solana-keygen`
  /// accepts via `--word-count`: 12, 15, 18, 21, or 24.
  static const List<int> validWordCounts = [12, 15, 18, 21, 24];

  /// Number of bits each wordlist index encodes.
  static const int _bitsPerWord = 11;

  /// Generates a new, random BIP-39 mnemonic.
  ///
  /// [wordCount] defaults to 12, the same default `solana-keygen new`
  /// uses, and must be one of [validWordCounts].
  ///
  /// Throws [ArgumentError] if [wordCount] is not one of
  /// [validWordCounts].
  static Future<Bip39Mnemonic> generate({int wordCount = 12}) async {
    if (!validWordCounts.contains(wordCount)) {
      throw ArgumentError.value(
        wordCount,
        'wordCount',
        'Must be one of $validWordCounts',
      );
    }

    // ENT (entropy bits) relates to word count as ENT = wordCount * 32/3,
    // per the table in the BIP-39 spec (12 words -> 128 bits of entropy,
    // 24 words -> 256 bits, and so on for the values in between).
    final entropyBits = wordCount * 32 ~/ 3;
    final entropyBytes = entropyBits ~/ 8;

    // Draw the entropy from a cryptographically secure random source.
    final random = Random.secure();
    final entropy = Uint8List.fromList(
      List<int>.generate(entropyBytes, (_) => random.nextInt(256)),
    );

    final words = await _entropyToWords(entropy);
    return Bip39Mnemonic._(words.join(' '), words);
  }

  /// Restores a mnemonic from an existing [phrase], validating its
  /// checksum.
  ///
  /// Throws [ArgumentError] if the word count is not one of
  /// [validWordCounts], if any word is not in the official English
  /// wordlist, or if the checksum does not match, which catches a
  /// mistyped or corrupted phrase instead of silently accepting it.
  static Future<Bip39Mnemonic> fromPhrase(String phrase) async {
    final words = phrase.trim().split(RegExp(r'\s+'));

    if (!validWordCounts.contains(words.length)) {
      throw ArgumentError.value(
        words.length,
        'phrase (word count)',
        'Must be one of $validWordCounts words',
      );
    }

    // Look up each word's index in the official wordlist; an unknown
    // word means this was never a valid BIP-39 phrase to begin with.
    final indices = <int>[];
    for (final word in words) {
      final index = bip39EnglishWordlist.indexOf(word);
      if (index == -1) {
        throw ArgumentError.value(
          word,
          'phrase',
          'Not a word in the official BIP-39 English wordlist',
        );
      }
      indices.add(index);
    }

    if (!await _checksumIsValid(indices)) {
      throw ArgumentError.value(
        phrase,
        'phrase',
        'Checksum does not match; this is not a valid BIP-39 mnemonic',
      );
    }

    return Bip39Mnemonic._(words.join(' '), words);
  }

  /// Derives the 64-byte BIP-39 seed from this mnemonic, via
  /// PBKDF2-HMAC-SHA512 with 2048 iterations, as the spec requires.
  ///
  /// [passphrase] is the optional BIP-39 passphrase (sometimes called
  /// the "25th word"); a different passphrase derives a completely
  /// different, unrelated seed from the same mnemonic phrase.
  ///
  /// The BIP-39 spec requires both the mnemonic sentence and the
  /// passphrase to be Unicode NFKD-normalized before use. Dart's
  /// standard library has no NFKD implementation, and the official
  /// English wordlist is pure ASCII (where NFKD is a no-op), so
  /// [passphrase] is restricted to ASCII for now: silently skipping
  /// normalization for a non-ASCII passphrase would derive a seed
  /// that disagrees with every other BIP-39 wallet given the same
  /// passphrase, which is a correctness problem, not a cosmetic one.
  ///
  /// Throws [ArgumentError] if [passphrase] contains non-ASCII
  /// characters.
  Future<Uint8List> toSeed({String passphrase = ''}) async {
    if (!_isAscii(passphrase)) {
      throw ArgumentError.value(
        passphrase,
        'passphrase',
        'Only ASCII passphrases are supported for now (BIP-39 requires '
            'Unicode NFKD normalization, which Dart has no built-in '
            'support for; ASCII text is unaffected by NFKD)',
      );
    }

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha512(),
      iterations: 2048,
      bits: 512,
    );

    // BIP-39's salt is the fixed string "mnemonic" with the passphrase
    // appended directly, no separator; an empty passphrase just
    // leaves the salt as "mnemonic".
    final seedKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(phrase)),
      nonce: utf8.encode('mnemonic$passphrase'),
    );

    return Uint8List.fromList(await seedKey.extractBytes());
  }

  /// Converts [entropy] into its mnemonic words: appends the BIP-39
  /// checksum bits (the first ENT/32 bits of SHA-256(entropy)) before
  /// splitting the result into 11-bit groups, each an index into
  /// [bip39EnglishWordlist].
  static Future<List<String>> _entropyToWords(Uint8List entropy) async {
    final checksumBits = entropy.length * 8 ~/ 32;
    final hash = await Sha256().hash(entropy);
    final bits = _bytesToBits(entropy) +
        _bytesToBits(Uint8List.fromList(hash.bytes)).sublist(0, checksumBits);

    final words = <String>[];
    for (var i = 0; i < bits.length; i += _bitsPerWord) {
      final index = _bitsToInt(bits.sublist(i, i + _bitsPerWord));
      words.add(bip39EnglishWordlist[index]);
    }
    return words;
  }

  /// Recomputes the checksum for the entropy encoded by [indices] and
  /// compares it against the checksum bits already embedded in them.
  static Future<bool> _checksumIsValid(List<int> indices) async {
    final totalBits = indices.length * _bitsPerWord;
    final checksumBits = totalBits ~/ 33;
    final entropyBitCount = totalBits - checksumBits;

    final allBits = <bool>[];
    for (final index in indices) {
      allBits.addAll(_intToBits(index, _bitsPerWord));
    }

    final entropyBitsList = allBits.sublist(0, entropyBitCount);
    final embeddedChecksumBits = allBits.sublist(entropyBitCount);

    final entropyBytes = _bitsToBytes(entropyBitsList);
    final hash = await Sha256().hash(entropyBytes);
    final expectedChecksumBits =
        _bytesToBits(Uint8List.fromList(hash.bytes)).sublist(0, checksumBits);

    for (var i = 0; i < checksumBits; i++) {
      if (embeddedChecksumBits[i] != expectedChecksumBits[i]) return false;
    }
    return true;
  }

  static List<bool> _bytesToBits(Uint8List bytes) {
    final bits = <bool>[];
    for (final byte in bytes) {
      for (var i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1 == 1);
      }
    }
    return bits;
  }

  static int _bitsToInt(List<bool> bits) {
    var value = 0;
    for (final bit in bits) {
      value = (value << 1) | (bit ? 1 : 0);
    }
    return value;
  }

  static List<bool> _intToBits(int value, int width) {
    final bits = <bool>[];
    for (var i = width - 1; i >= 0; i--) {
      bits.add((value >> i) & 1 == 1);
    }
    return bits;
  }

  static Uint8List _bitsToBytes(List<bool> bits) {
    final bytes = Uint8List(bits.length ~/ 8);
    for (var i = 0; i < bytes.length; i++) {
      var byte = 0;
      for (var j = 0; j < 8; j++) {
        byte = (byte << 1) | (bits[i * 8 + j] ? 1 : 0);
      }
      bytes[i] = byte;
    }
    return bytes;
  }

  static bool _isAscii(String value) => value.codeUnits.every((c) => c < 128);
}
