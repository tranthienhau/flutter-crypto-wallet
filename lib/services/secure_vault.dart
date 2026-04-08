// Secure vault for mnemonic and private keys.
// Wraps flutter_secure_storage which maps to Keychain (iOS) and Keystore
// (Android) with WHEN_UNLOCKED_THIS_DEVICE_ONLY semantics.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureVault {
  const SecureVault();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _mnemonicKey = 'wallet_mnemonic';

  Future<String?> readMnemonic() => _storage.read(key: _mnemonicKey);

  Future<void> writeMnemonic(String mnemonic) =>
      _storage.write(key: _mnemonicKey, value: mnemonic);

  Future<void> clearVault() => _storage.delete(key: _mnemonicKey);
}
