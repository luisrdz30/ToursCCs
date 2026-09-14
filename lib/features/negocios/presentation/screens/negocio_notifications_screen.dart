import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class NegocioNotificationsScreen extends StatefulWidget {
  const NegocioNotificationsScreen({super.key});

  @override
  State<NegocioNotificationsScreen> createState() => _NegocioNotificationsScreenState();
}

class _NegocioNotificationsScreenState extends State<NegocioNotificationsScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'Promoción Aprobada',
      'message': 'Tu solicitud de evento "Noche de Flamenco Auténtico" ha sido aprobada por el administrador.',
      'time': 'Hace 2 horas',
      'isPinned': true,
      'isUnread': true,
      'icon': Icons.check_circle_outline,
      'route': '/negocios', // routes back to promos or something
    },
    {
      'id': '2',
      'title': 'Nuevo escaneo registrado',
      'message': 'Se ha escaneado el código QR de un turista y se le asignaron 50 puntos.',
      'time': 'Hace 3 horas',
      'isPinned': false,
      'isUnread': true,
      'icon': Icons.qr_code_scanner,
      'route': null,
    },
    {
      'id': '3',
      'title': 'Resumen Semanal',
      'message': 'Tu comercio generó 1.2K puntos en recompensas esta semana. Toca para ver detalles.',
      'time': 'Ayer',
      'isPinned': false,
      'isUnread': false,
      'icon': Icons.insights,
      'route': '/negocios',
    },
  ];

  void _togglePin(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index]['isPinned'] = !notifications[index]['isPinned'];
        notifications.sort((a, b) {
          if (a['isPinned'] && !b['isPinned']) return -1;
          if (!a['isPinned'] && b['isPinned']) return 1;
          return 0; 
        });
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n['id'] == id);
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
          'Notificaciones de Negocio',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primary),
            onPressed: () {
              setState(() {
                for (var n in notifications) {
                  n['isUnread'] = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas marcadas como leídas')),
              );
            },
          )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(notif);
              },
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

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    return Dismissible(
      key: Key(notif['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notif['id']),
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
          if (notif['route'] != null) {
            context.push(notif['route']);
          }
          setState(() {
            notif['isUnread'] = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif['isUnread'] ? AppTheme.primaryContainer.withValues(alpha: 0.3) : AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: notif['isUnread'] ? Border.all(color: AppTheme.primary.withValues(alpha: 0.2)) : null,
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
                  color: notif['isUnread'] ? AppTheme.primary : AppTheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notif['icon'],
                  color: notif['isUnread'] ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
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
                            notif['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          notif['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: notif['isUnread'] ? AppTheme.primary : AppTheme.onSurfaceVariant,
                            fontWeight: notif['isUnread'] ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif['message'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  notif['isPinned'] ? Icons.push_pin : Icons.push_pin_outlined,
                  color: notif['isPinned'] ? AppTheme.primary : AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () => _togglePin(notif['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
