import 'package:flutter_test/flutter_test.dart';
import 'package:solana_flutter_sdk/src/crypto/bip39/bip39_mnemonic.dart';
import 'package:solana_flutter_sdk/src/crypto/bip39/bip39_wordlist.dart';

void main() {
  group('Bip39Mnemonic.generate', () {
    test('defaults to 12 words', () async {
      final mnemonic = await Bip39Mnemonic.generate();
      expect(mnemonic.words.length, 12);
    });

    test('supports every valid word count', () async {
      for (final wordCount in Bip39Mnemonic.validWordCounts) {
        final mnemonic = await Bip39Mnemonic.generate(wordCount: wordCount);
        expect(mnemonic.words.length, wordCount);
      }
    });

    test('every generated word is in the official wordlist', () async {
      final mnemonic = await Bip39Mnemonic.generate(wordCount: 24);
      for (final word in mnemonic.words) {
        expect(bip39EnglishWordlist.contains(word), isTrue);
      }
    });

    test('phrase is the words joined by single spaces', () async {
      final mnemonic = await Bip39Mnemonic.generate();
      expect(mnemonic.phrase, mnemonic.words.join(' '));
    });

    test('rejects an invalid word count', () {
      expect(
        () => Bip39Mnemonic.generate(wordCount: 13),
        throwsArgumentError,
      );
    });

    test('produces a mnemonic that round-trips through fromPhrase', () async {
      final generated = await Bip39Mnemonic.generate(wordCount: 24);
      final restored = await Bip39Mnemonic.fromPhrase(generated.phrase);
      expect(restored.words, generated.words);
    });

    test('two generated mnemonics are not identical', () async {
      final first = await Bip39Mnemonic.generate();
      final second = await Bip39Mnemonic.generate();
      expect(first.phrase == second.phrase, isFalse);
    });
  });

  group('Bip39Mnemonic.fromPhrase', () {
    // Official BIP-39 test vector (all-zero entropy, 12 words), from
    // the reference test vectors used by the Bitcoin BIP-39 spec and
    // the python-mnemonic reference library.
    const zeroEntropyPhrase =
        'abandon abandon abandon abandon abandon abandon abandon abandon '
        'abandon abandon abandon about';

    test('accepts a valid phrase', () async {
      final mnemonic = await Bip39Mnemonic.fromPhrase(zeroEntropyPhrase);
      expect(mnemonic.words.length, 12);
      expect(mnemonic.phrase, zeroEntropyPhrase);
    });

    test('rejects a word count outside the valid set', () {
      expect(
        () => Bip39Mnemonic.fromPhrase('abandon abandon abandon'),
        throwsArgumentError,
      );
    });

    test('rejects a word not in the official wordlist', () {
      final phrase = zeroEntropyPhrase.replaceFirst('about', 'notaword');
      expect(() => Bip39Mnemonic.fromPhrase(phrase), throwsArgumentError);
    });

    test('rejects a phrase with a bad checksum', () {
      // Swap the last word for another valid wordlist entry; this
      // keeps every word valid but breaks the checksum.
      final phrase = zeroEntropyPhrase.replaceFirst(
        RegExp(r'about$'),
        'zoo',
      );
      expect(() => Bip39Mnemonic.fromPhrase(phrase), throwsArgumentError);
    });

    test('tolerates surrounding and repeated whitespace', () async {
      final messyPhrase = '  ${zeroEntropyPhrase.replaceAll(' ', '   ')}  ';
      final mnemonic = await Bip39Mnemonic.fromPhrase(messyPhrase);
      expect(mnemonic.words.length, 12);
    });
  });

  group('Bip39Mnemonic.toSeed', () {
    test('matches the official BIP-39 test vector with a passphrase', () async {
      // Official BIP-39 test vector: 12-word all-zero-entropy phrase
      // + passphrase "TREZOR", verified independently against the
      // python-mnemonic reference library's own PBKDF2 output.
      const phrase =
          'abandon abandon abandon abandon abandon abandon abandon abandon '
          'abandon abandon abandon about';
      const expectedSeedHex =
          'c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e534955'
          '31f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b'
          '04';

      final mnemonic = await Bip39Mnemonic.fromPhrase(phrase);
      final seed = await mnemonic.toSeed(passphrase: 'TREZOR');

      expect(seed.length, 64);
      expect(_toHex(seed), expectedSeedHex);
    });

    test('an empty passphrase derives a different seed than a non-empty one',
        () async {
      final mnemonic = await Bip39Mnemonic.generate();
      final seedNoPassphrase = await mnemonic.toSeed();
      final seedWithPassphrase = await mnemonic.toSeed(passphrase: 'test');
      expect(_toHex(seedNoPassphrase) == _toHex(seedWithPassphrase), isFalse);
    });

    test('deriving the same mnemonic and passphrase twice is deterministic',
        () async {
      final mnemonic = await Bip39Mnemonic.generate();
      final seed1 = await mnemonic.toSeed(passphrase: 'same');
      final seed2 = await mnemonic.toSeed(passphrase: 'same');
      expect(_toHex(seed1), _toHex(seed2));
    });

    test('rejects a non-ASCII passphrase', () async {
      final mnemonic = await Bip39Mnemonic.generate();
      expect(
        () => mnemonic.toSeed(passphrase: 'cafÃ©'),
        throwsArgumentError,
      );
    });

    test('seed is always 64 bytes regardless of word count', () async {
      for (final wordCount in Bip39Mnemonic.validWordCounts) {
        final mnemonic = await Bip39Mnemonic.generate(wordCount: wordCount);
        final seed = await mnemonic.toSeed();
        expect(seed.length, 64);
      }
    });
  });
}

String _toHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
