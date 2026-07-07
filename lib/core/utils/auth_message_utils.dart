/// Normalizes auth API error messages to translation keys for consistent FR/AR display.

class AuthMessageUtils {
  AuthMessageUtils._();

  /// Returns a translation key for the given API [message] and optional [status].
  /// Use in UI: AuthMessageUtils.normalizeToKey(msg, status).tr(locale)
  static String normalizeToKey(String? message, [String? status]) {
    if (message == null || message.isEmpty) {
      return 'auth_error_generic';
    }

    final m = message.toLowerCase().trim();
    final s = (status ?? '').toLowerCase();

    // Registration status from backend
    if (s == 'invalid_register_method') return 'invalid_register_method';

    // Connection / network
    if (m.contains('connection') || m.contains('connexion') ||
        m.contains('network') || m.contains('réseau') ||
        m.contains('timeout') || m.contains('socket')) {
      return 'auth_connection_error';
    }

    // Login
    if (m.contains('login failed') || m.contains('échec') && m.contains('connexion') ||
        m.contains('invalid credentials') || m.contains('incorrect') ||
        m.contains('unauthorized') || m.contains('unauthenticated') ||
        m.contains('wrong password') || m.contains('mauvais') ||
        m.contains('user not found') || m.contains('utilisateur introuvable')) {
      return 'auth_invalid_credentials';
    }

    // Registration
    if (m.contains('registration failed') || m.contains('inscription') && m.contains('échou')) {
      return 'auth_registration_failed';
    }
    if (m.contains('email') && (m.contains('already') || m.contains('déjà') || m.contains('taken') || m.contains('exist'))) {
      return 'auth_email_already_used';
    }
    if ((m.contains('phone') || m.contains('mobile') || m.contains('téléphone')) &&
        (m.contains('already') || m.contains('déjà') || m.contains('taken') || m.contains('exist'))) {
      return 'auth_phone_already_used';
    }

    // Verification
    if (m.contains('verification') || m.contains('code') && (m.contains('invalid') || m.contains('expired'))) {
      return 'auth_verification_failed';
    }

    // User ID not found (e.g. complete profile / verify without session)
    if (m.contains('user id not found') || m.contains('user_id')) {
      return 'auth_user_not_found';
    }

    return 'auth_error_generic';
  }
}
