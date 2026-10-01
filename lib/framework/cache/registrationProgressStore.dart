import 'package:get_storage/get_storage.dart';

enum RegistrationStep { otp, awaitingApproval }

class RegistrationProgress {
  const RegistrationProgress({
    required this.step,
    required this.email,
    required this.role,
  });

  final RegistrationStep step;
  final String email;
  final String role;
}

/// Persists only the minimum non-sensitive data needed to resume registration.
class RegistrationProgressStore {
  RegistrationProgressStore({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const _key = 'registration_progress_v1';
  final GetStorage _storage;

  RegistrationProgress? read() {
    final raw = _storage.read(_key);
    if (raw is! Map) return null;

    final email = raw['email']?.toString().trim() ?? '';
    final role = raw['role']?.toString().trim() ?? '';
    final stepName = raw['step']?.toString();
    RegistrationStep? step;
    for (final value in RegistrationStep.values) {
      if (value.name == stepName) step = value;
    }

    if (email.isEmpty || role.isEmpty || step == null) return null;
    return RegistrationProgress(step: step, email: email, role: role);
  }

  Future<void> saveOtp({required String email, required String role}) {
    return _write(RegistrationStep.otp, email, role);
  }

  Future<void> saveAwaitingApproval({
    required String email,
    required String role,
  }) {
    return _write(RegistrationStep.awaitingApproval, email, role);
  }

  Future<void> clear() => _storage.remove(_key);

  Future<void> _write(RegistrationStep step, String email, String role) {
    return _storage.write(_key, {
      'step': step.name,
      'email': email.trim().toLowerCase(),
      'role': role,
    });
  }
}
