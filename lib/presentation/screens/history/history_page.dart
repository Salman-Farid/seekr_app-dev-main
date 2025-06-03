import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/session_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserHistoryPage extends HookConsumerWidget {
  static const String routeName = 'user-history';
  static const String routePath = '/user-history';
  const UserHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(userHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User History'),
        centerTitle: true,
      ),
      body: historyState.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Text('No history available'),
            );
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final log = history[index];
              return Card(
                child: ListTile(
                  title: Text('${log.feature.name} detection'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(timeago.format(log.createdAt),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(log.event.details),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
