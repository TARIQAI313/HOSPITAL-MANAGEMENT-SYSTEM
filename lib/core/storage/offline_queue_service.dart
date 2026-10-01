import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'local_cache_service.dart';

class OfflineAction {
  final String id;
  final String actionType; // 'book_appointment', 'log_vital', 'medication_taken', etc.
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  OfflineAction({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'actionType': actionType,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
    id: json['id'] as String,
    actionType: json['actionType'] as String,
    payload: Map<String, dynamic>.from(json['payload'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class OfflineQueueService {
  static const _queueKey = 'auracare_offline_queue';

  static Future<void> enqueue(String actionType, Map<String, dynamic> payload) async {
    final cache = await LocalCacheService.getInstance();
    final list = await getPendingActions();
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: actionType,
      payload: payload,
      createdAt: DateTime.now(),
    );
    list.add(action);
    await cache.saveString(_queueKey, jsonEncode(list.map((e) => e.toJson()).toList()));
    debugPrint('Offline action enqueued: $actionType (total in queue: ${list.length})');
  }

  static Future<List<OfflineAction>> getPendingActions() async {
    final cache = await LocalCacheService.getInstance();
    final str = cache.getString(_queueKey);
    if (str == null || str.isEmpty) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((e) => OfflineAction.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearQueue() async {
    final cache = await LocalCacheService.getInstance();
    await cache.remove(_queueKey);
  }
}
