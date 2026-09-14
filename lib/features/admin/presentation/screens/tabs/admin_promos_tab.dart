import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/theme/app_theme.dart';

class AdminPromosTab extends StatefulWidget {
  const AdminPromosTab({super.key});

  @override
  State<AdminPromosTab> createState() => _AdminPromosTabState();
}

class _AdminPromosTabState extends State<AdminPromosTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: const Icon(Icons.storefront, color: AppTheme.primary),
        title: const Text(
          'Promociones',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicitudes de Promociones',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Revisa y aprueba las ofertas de los negocios afiliados',
                  style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: AppTheme.primaryContainer,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppTheme.onPrimaryContainer,
                    unselectedLabelColor: AppTheme.onSurfaceVariant,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Pendientes', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream: _db.collection('promotions').where('isApproved', isEqualTo: false).snapshots(),
                              builder: (context, snapshot) {
                                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                                if (count == 0) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(color: AppTheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      const Tab(
                        child: Text('Aprobados', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPromoList(isApproved: false),
                _buildPromoList(isApproved: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoList({required bool isApproved}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('promotions').where('isApproved', isEqualTo: isApproved).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              isApproved ? 'No hay promociones aprobadas.' : 'No hay promociones pendientes.',
              style: const TextStyle(color: AppTheme.onSurfaceVariant),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: docs.length + 1, // +1 for bottom padding
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == docs.length) return const SizedBox(height: 100);
            
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildPromoCard(doc.id, data, isApproved);
          },
        );
      },
    );
  }

  Widget _buildPromoCard(String id, Map<String, dynamic> data, bool isApproved) {
    final imageUrl = data['imageUrl'] ?? 'https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?q=80';
    final title = data['title'] ?? 'Sin título';
    final desc = data['description'] ?? 'Sin descripción';
    final partnerName = data['businessName'] ?? 'Negocio Desconocido';
    final isActive = data['isActive'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(39, 101, 124, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 160, color: Colors.grey[200]),
              ),
              if (isApproved)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isActive ? 'ACTIVO' : 'INACTIVO',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partnerName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.tertiary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: isApproved ? Colors.green : AppTheme.tertiary),
                        const SizedBox(width: 8),
                        Text(
                          isApproved ? 'Estado: Aprobado' : 'Estado: Pendiente',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (!isApproved)
                      ElevatedButton(
                        onPressed: () {
                          // Quick mock of approval
                          _db.collection('promotions').doc(id).update({'isApproved': true});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                        ),
                        child: const Text('Aprobar'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          _db.collection('promotions').doc(id).update({'isActive': !isActive});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.red : Colors.green,
                          foregroundColor: AppTheme.onPrimary,
                        ),
                        child: Text(isActive ? 'Pausar' : 'Reactivar'),
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
