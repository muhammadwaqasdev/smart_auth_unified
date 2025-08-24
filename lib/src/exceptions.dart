class SmartAuthException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  SmartAuthException(this.message, {this.code, this.cause});

  @override
  String toString() =>
      'SmartAuthException(code: ${code ?? 'n/a'}, message: $message)';
}

class ProviderNotRegisteredException extends SmartAuthException {
  ProviderNotRegisteredException(String provider)
    : super(
        'Provider not registered: $provider',
        code: 'provider_not_registered',
      );
}

class StorageException extends SmartAuthException {
  StorageException(super.message, {super.cause}) : super(code: 'storage_error');
}

class BiometricException extends SmartAuthException {
  BiometricException(super.message, {super.cause})
    : super(code: 'biometric_error');
}
