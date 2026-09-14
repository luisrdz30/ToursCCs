import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/notification_dto.dart';
import 'package:intl/intl.dart';

class ChoferNotificationsScreen extends StatefulWidget {
  const ChoferNotificationsScreen({super.key});

  @override
  State<ChoferNotificationsScreen> createState() => _ChoferNotificationsScreenState();
}

class _ChoferNotificationsScreenState extends State<ChoferNotificationsScreen> {
  final ApiClient _apiClient = ApiClient();
  Future<List<NotificationDto>>? _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _apiClient.dio.get('/notifications').then((response) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationDto.fromJson(json)).toList();
      });
    });
  }

  void _markAllAsRead() {
    _apiClient.dio.put('/notifications/read-all').then((_) {
      _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas marcadas como leídas')),
      );
    }).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al marcar leídas')),
      );
    });
  }

  void _deleteNotification(String id) {
    // Ideally this would call a DELETE endpoint
    _apiClient.dio.delete('/notifications/$id').then((_) {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primary),
            onPressed: () {
//              setState(() {
//                for (var n in notifications) {
//                  n['isUnread'] = false;
//                }
//              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas marcadas como leídas')),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<NotificationDto>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}', style: const TextStyle(color: AppTheme.error)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationCard(notif);
            },
          );
        }
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: AppTheme.surfaceContainerHighest),
          const SizedBox(height: 16),
          const Text(
            'Estás al día',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No tienes notificaciones pendientes',
            style: TextStyle(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationDto notif) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notif.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          if (notif.actionRoute != null) {
            context.push(notif.actionRoute!);
          }
          if (notif.isUnread) {
             _apiClient.dio.put('/notifications/\${notif.id}/read').then((_) {
               _loadNotifications();
             });
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.isUnread ? AppTheme.primaryContainer.withValues(alpha: 0.3) : AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: notif.isUnread ? Border.all(color: AppTheme.primary.withValues(alpha: 0.2)) : null,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(39, 101, 124, 0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notif.isUnread ? AppTheme.primary : AppTheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: notif.isUnread ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat.MMMd().format(notif.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: notif.isUnread ? AppTheme.primary : AppTheme.onSurfaceVariant,
                            fontWeight: notif.isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
