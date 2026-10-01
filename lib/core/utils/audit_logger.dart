import 'package:flutter/foundation.dart';
import '../network/supabase_client.dart';

class AuditLogger {
  AuditLogger._();

  static Future<void> logAction({
    required String action,
    required String entity,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    final client = SupabaseService.client;
    final timestamp = DateTime.now().toUtc().toIso8601String();

    debugPrint('AUDIT: [$timestamp] $action on $entity (ID: $entityId) - Meta: $metadata');

    if (client != null) {
      try {
        await client.from('audit_logs').insert({
          'action': action,
          'entity': entity,
          'entity_id': entityId,
          'metadata': metadata ?? {},
        });
      } catch (e) {
        debugPrint('Audit logging to database deferred: $e');
      }
    }
  }
}
