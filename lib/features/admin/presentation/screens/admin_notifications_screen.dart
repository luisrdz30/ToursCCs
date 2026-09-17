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

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = FirebaseFirestore.instance;
  // Use a hardcoded dummy user ID for testing if auth is not ready
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'dummy_admin_user_id';

  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  bool _showScrollTop = false;
  String _filterMode = 'Todas'; // 'Todas', 'Activas', 'Inactivas'
  String _targetFilter = 'Todos'; // 'Todos', 'Turistas', 'Choferes', 'Negocios'

  late Stream<DocumentSnapshot> _userStream;
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _userStream = _db.collection('users').doc(_userId).snapshots();
    _notificationsStream = _db.collection('notifications').orderBy('createdAt', descending: true).snapshots();
    
    void scrollListener() {
      final ctrl = _tabController.index == 0 ? _scrollController1 : _scrollController2;
      if (ctrl.hasClients) {
        if (ctrl.offset > 200 && !_showScrollTop) {
          setState(() => _showScrollTop = true);
        } else if (ctrl.offset <= 200 && _showScrollTop) {
          setState(() => _showScrollTop = false);
        }
      }
    }
    
    _scrollController1.addListener(scrollListener);
    _scrollController2.addListener(scrollListener);
    _tabController.addListener(() {
      setState(() {
        final ctrl = _tabController.index == 0 ? _scrollController1 : _scrollController2;
        _showScrollTop = ctrl.hasClients && ctrl.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  void _markAsRead(String id) async {
    await _db.collection('users').doc(_userId).set({
      'readNotifications': FieldValue.arrayUnion([id])
    }, SetOptions(merge: true));
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceVariant,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<DocumentSnapshot> docs, List<dynamic> readList, bool showRead, ScrollController controller) {
    // Filter out old notifications (> 20 days)
    final cutoffDate = DateTime.now().subtract(const Duration(days: 20));
    
    final filteredDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'] as Timestamp?;
      if (createdAt != null && createdAt.toDate().isBefore(cutoffDate)) {
        return false; // Hide if older than 20 days
      }
      
      final isActive = data['isActive'] ?? true;
      if (_filterMode == 'Activas' && !isActive) return false;
      if (_filterMode == 'Inactivas' && isActive) return false;
      
      final targetRole = data['targetRole'] ?? 'all';
      if (_targetFilter == 'Turistas' && targetRole != 'tourist') return false;
      if (_targetFilter == 'Choferes' && targetRole != 'driver') return false;
      if (_targetFilter == 'Negocios' && targetRole != 'business') return false;

      final isRead = readList.contains(doc.id);
      return showRead ? isRead : !isRead;
    }).toList();

    // Sort pinned to the top
    filteredDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aPinned = aData['isPinned'] ?? false;
      final bPinned = bData['isPinned'] ?? false;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0; // maintain existing order
    });

    if (filteredDocs.isEmpty) {
      return _buildEmptyState(showRead ? 'No hay notificaciones leídas' : 'No tienes notificaciones nuevas');
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final doc = filteredDocs[index];
        final data = doc.data() as Map<String, dynamic>;
        
        final targetRole = data['targetRole'] ?? 'all';
        String roleTag = '';
        Color roleColor = Colors.grey;
        if (targetRole == 'tourist') { roleTag = 'Turistas'; roleColor = Colors.blue; }
        else if (targetRole == 'driver') { roleTag = 'Choferes'; roleColor = Colors.orange; }
        else if (targetRole == 'business') { roleTag = 'Negocios'; roleColor = Colors.green; }
        else { roleTag = 'Todos'; roleColor = AppTheme.primary; }

        final notif = {
          'id': doc.id,
          'title': data['title'] ?? 'Sin título',
          'message': data['message'] ?? '',
          'time': data['createdAt'] != null 
              ? _formatTimestamp(data['createdAt'] as Timestamp) 
              : 'Ahora',
          'isPinned': data['isPinned'] ?? false,
          'isActive': data['isActive'] ?? true,
          'isUnread': !showRead,
          'icon': Icons.notifications,
          'roleTag': roleTag,
          'roleColor': roleColor,
        };

        return _buildNotificationCard(notif);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final bool isUnread = notif['isUnread'];
    final bool isPinned = notif['isPinned'];
    final bool isActive = notif['isActive'];
    final String roleTag = notif['roleTag'] ?? '';
    final Color roleColor = notif['roleColor'] ?? Colors.grey;
    
    return GestureDetector(
      onTap: () {
        if (isUnread) _markAsRead(notif['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? AppTheme.surfaceContainerLowest : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? AppTheme.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
          boxShadow: [
            if (isUnread)
              const BoxShadow(
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
                color: isUnread ? AppTheme.primaryContainer : AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(notif['icon'], color: isUnread ? AppTheme.primary : AppTheme.onSurfaceVariant),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: isPinned ? AppTheme.primary : AppTheme.onSurfaceVariant,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _db.collection('notifications').doc(notif['id']).update({
                            'isPinned': !isPinned
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnread ? AppTheme.onSurface : AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            notif['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              roleTag,
                              style: TextStyle(fontSize: 10, color: roleColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            isActive ? 'Activa' : 'Inactiva',
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (val) {
                              _db.collection('notifications').doc(notif['id']).update({
                                'isActive': val
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedTarget = 'Todos'; // Todos, Turistas, Choferes, Negocios

    showDialog(
      context: context,
      builder: (context) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            scrollable: true,
            title: const Text('Enviar Notificación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTarget,
                  decoration: InputDecoration(
                    labelText: 'Dirigido a',
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: ['Todos', 'Turistas', 'Choferes', 'Negocios'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedTarget = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Mensaje',
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: isSending ? null : () async {
                  if (titleController.text.trim().isEmpty || messageController.text.trim().isEmpty) return;
                  
                  setDialogState(() => isSending = true);
                  final db = FirebaseFirestore.instance;
                  
                  String targetRoleDb = 'all';
                  if (selectedTarget == 'Turistas') targetRoleDb = 'tourist';
                  if (selectedTarget == 'Choferes') targetRoleDb = 'driver';
                  if (selectedTarget == 'Negocios') targetRoleDb = 'business';

                  await db.collection('notifications').add({
                    'title': titleController.text.trim(),
                    'message': messageController.text.trim(),
                    'targetRole': targetRoleDb,
                    'createdAt': FieldValue.serverTimestamp(),
                    'isPinned': false,
                    'isActive': true,
                  });

                  if (context.mounted) {
                    setDialogState(() => isSending = false);
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notificación enviada a $selectedTarget')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary),
                child: isSending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.onPrimary)) : const Text('Enviar'),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: _showScrollTop ? FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.arrow_upward, color: AppTheme.onPrimary),
        onPressed: () {
          final ctrl = _tabController.index == 0 ? _scrollController1 : _scrollController2;
          if (ctrl.hasClients) {
            ctrl.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
      ) : null,
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
            icon: const Icon(Icons.add_alert, color: AppTheme.primary), // Botón para crear notificación
            onPressed: _showAddNotificationDialog,
            tooltip: 'Enviar Notificación',
          ),
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primary),
            tooltip: 'Marcar todas como leídas',
            onPressed: () async {
              final query = await _db.collection('notifications').get();
              final List<String> allIds = query.docs.map((e) => e.id).toList();
              await _db.collection('users').doc(_userId).set({
                'readNotifications': FieldValue.arrayUnion(allIds)
              }, SetOptions(merge: true));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas marcadas como leídas')),
                );
              }
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceVariant,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'No Leídas'),
            Tab(text: 'Leídas'),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, userSnapshot) {
          final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
          final List<dynamic> readNotifications = userData['readNotifications'] ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final allDocs = snapshot.data?.docs ?? [];
              
              // Only Admin can see inactive notifications in this screen, but maybe tourists won't see them
              final visibleDocs = allDocs.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppTheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...['Todas', 'Activas', 'Inactivas'].map((mode) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(mode),
                                selected: _filterMode == mode,
                                onSelected: (selected) {
                                  if (selected) setState(() => _filterMode = mode);
                                },
                                selectedColor: AppTheme.primaryContainer,
                                checkmarkColor: AppTheme.primary,
                                labelStyle: TextStyle(
                                  color: _filterMode == mode ? AppTheme.primary : AppTheme.onSurfaceVariant,
                                  fontWeight: _filterMode == mode ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          const VerticalDivider(width: 16, indent: 8, endIndent: 8, color: Colors.grey),
                          ...['Todos', 'Turistas', 'Choferes', 'Negocios'].map((mode) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(mode),
                                selected: _targetFilter == mode,
                                onSelected: (selected) {
                                  if (selected) setState(() => _targetFilter = mode);
                                },
                                selectedColor: Colors.blue.withValues(alpha: 0.1),
                                checkmarkColor: Colors.blue,
                                labelStyle: TextStyle(
                                  color: _targetFilter == mode ? Colors.blue.shade800 : AppTheme.onSurfaceVariant,
                                  fontWeight: _targetFilter == mode ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildNotificationList(visibleDocs, readNotifications, false, _scrollController1), // No leídas
                        _buildNotificationList(visibleDocs, readNotifications, true, _scrollController2),  // Leídas
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }
      ),
    );
  }
}
