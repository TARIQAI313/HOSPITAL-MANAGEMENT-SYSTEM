import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationRepository {
  final List<NotificationModel> _demoNotifications = [
    NotificationModel(
      id: 'n-1',
      userId: '30000000-0000-0000-0000-000000000001',
      title: 'Appointment Confirmed',
      body: 'Your consultation with Dr. Sarah Watson is scheduled for tomorrow at 09:30 AM.',
      type: 'appointment',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    NotificationModel(
      id: 'n-2',
      userId: '30000000-0000-0000-0000-000000000001',
      title: 'Pill Reminder: Atorvastatin',
      body: 'Time to take your 20mg Atorvastatin pill with water before bed.',
      type: 'medication',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'n-3',
      userId: '30000000-0000-0000-0000-000000000001',
      title: 'Lab Results Ready',
      body: 'Your Complete Blood Count (CBC) test report is now verified and available for download.',
      type: 'lab',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    NotificationModel(
      id: 'n-4',
      userId: '30000000-0000-0000-0000-000000000001',
      title: 'Payment Invoice Generated',
      body: 'Invoice INV-2026-0001 for \$157.50 is ready.',
      type: 'payment',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<NotificationModel>> getNotifications() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('notifications')
            .select()
            .order('created_at', ascending: false);
        return res.map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoNotifications;
  }

  Future<void> markAllAsRead() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('notifications').update({'is_read': true});
      } catch (_) {}
    }
  }
}
