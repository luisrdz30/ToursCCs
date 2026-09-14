import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  void _togglePin(String id) async {
    // Only updates local UI or global if admin wants it. We will leave global for now.
    final docRef = FirebaseFirestore.instance.collection('notifications').doc(id);
    final doc = await docRef.get();
    if (doc.exists) {
      final currentPin = doc.data()?['isPinned'] ?? false;
      await docRef.update({'isPinned': !currentPin});
    }
  }

  void _deleteNotification(String id) async {
    // Instead of deleting the global document, we add it to the user's hidden list
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'deletedNotifications': FieldValue.arrayUnion([id])
      });
    }
  }

  void _markAsRead(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'readNotifications': FieldValue.arrayUnion([id])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
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
            onPressed: () async {
              // Get all currently visible unread notifications and mark them as read for this user
              if (user != null) {
                final query = await FirebaseFirestore.instance.collection('notifications').get();
                final List<String> allIds = query.docs.map((e) => e.id).toList();
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  'readNotifications': FieldValue.arrayUnion(allIds)
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todas marcadas como leídas')),
                  );
                }
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSendNotificationDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.send, color: AppTheme.onPrimary),
        label: const Text('Enviar Mensaje', style: TextStyle(color: AppTheme.onPrimary, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Map firestore data to our local format for now to reuse _buildNotificationCard
              final notif = {
                'id': doc.id,
                'title': data['title'] ?? 'Sin título',
                'message': data['message'] ?? '',
                'time': data['createdAt'] != null 
                    ? _formatTimestamp(data['createdAt'] as Timestamp) 
                    : 'Ahora',
                'isPinned': data['isPinned'] ?? false,
                'isUnread': data['isUnread'] ?? true,
                'icon': Icons.notifications,
                'route': null,
              };
              
              return _buildNotificationCard(notif);
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else {
      return 'Hace ${diff.inDays} días';
    }
  }

  void _showSendNotificationDialog() {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String targetRole = 'Todos';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Enviar Notificación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: targetRole,
                  decoration: const InputDecoration(labelText: 'Destinatario'),
                  items: ['Todos', 'Negocios', 'Choferes', 'Turistas']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => targetRole = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageCtrl,
                  decoration: const InputDecoration(labelText: 'Mensaje'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || messageCtrl.text.isEmpty) return;
                
                // Add to firestore
                await FirebaseFirestore.instance.collection('notifications').add({
                  'title': titleCtrl.text,
                  'message': messageCtrl.text,
                  'targetRole': targetRole,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mensaje enviado exitosamente')));
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
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
          FirebaseFirestore.instance.collection('notifications').doc(notif['id']).update({'isUnread': false});
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
