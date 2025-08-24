import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isSupported() async {
    return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
  }

  Future<bool> authenticate({
    String reason = 'Please authenticate to proceed',
  }) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return success;
    } catch (_) {
      return false;
    }
  }
}
