// Face ID / Touch ID / fingerprint gate for sensitive actions.

import 'package:local_auth/local_auth.dart';

class BiometricsService {
  BiometricsService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> requestBiometric(String reason) async {
    try {
      final available = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      if (!available || !supported) {
        // Emulator fallback for POC testing.
        return true;
      }
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
