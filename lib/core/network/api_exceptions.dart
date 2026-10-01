class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const ApiException(this.message, {this.code, this.details});

  @override
  String toString() => 'ApiException: $message (code: $code)';

  static ApiException fromError(dynamic error) {
    if (error is ApiException) return error;
    final message = error.toString();
    if (message.contains('SocketException') || message.contains('Failed host lookup')) {
      return const ApiException('Network connection unavailable. Operating in offline/cached mode.', code: 'network_offline');
    }
    if (message.contains('JWT') || message.contains('token')) {
      return const ApiException('Your session has expired. Please sign in again.', code: 'auth_expired');
    }
    if (message.contains('Row-level security') || message.contains('violates row-level security')) {
      return const ApiException('Access denied. Insufficient permissions for this healthcare record.', code: 'rls_forbidden');
    }
    return ApiException(message, code: 'unknown');
  }
}
