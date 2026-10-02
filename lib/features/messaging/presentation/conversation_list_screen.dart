import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/search_field.dart';
import '../data/chat_repository.dart';
import '../domain/chat_model.dart';

final conversationListProvider = FutureProvider<List<ConversationSummaryModel>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getConversations();
});

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackScope(
      fallbackRoute: RoutePaths.home,
      child: Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Teal App Bar (Inspired by Reference UI)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: const BoxDecoration(
                gradient: AppColors.tealGradient,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.safePop(null, RoutePaths.home),
                      ),
                      const Text(
                        'Messages & Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_square, color: Colors.white, size: 22),
                        onPressed: () => context.push('/doctors'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SearchField(
                    hint: 'Search clinical conversations...',
                  ),
                ],
              ),
            ),

            // Conversation Tiles List
            Expanded(
              child: conversationsAsync.when(
                loading: () => const LoadingIndicator(message: 'Loading active channels...'),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No Conversations',
                      message: 'You have not initiated messaging with any physician or support care.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final item = conversations[idx];
                      return AppCard(
                        hasShadow: true,
                        onTap: () => context.push('/messages/${item.id}', extra: item),
                        child: Row(
                          children: [
                            AvatarWidget(
                              imageUrl: item.participantAvatar,
                              name: item.participantName,
                              size: 50,
                              showBadge: true,
                              isOnline: item.isOnline,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.participantName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        AppFormatters.formatTime(item.lastMessageTime),
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.lastMessage,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: item.unreadCount > 0 ? AppColors.text : AppColors.textSecondary,
                                            fontWeight: item.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.unreadCount > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${item.unreadCount}',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
