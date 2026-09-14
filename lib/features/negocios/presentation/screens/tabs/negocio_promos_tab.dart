import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/models/promotion_dto.dart';
import 'package:intl/intl.dart';

class NegocioPromosTab extends StatefulWidget {
  const NegocioPromosTab({super.key});

  @override
  State<NegocioPromosTab> createState() => _NegocioPromosTabState();
}

class _NegocioPromosTabState extends State<NegocioPromosTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTestData() async {
    final uid = (_auth.currentUser?.uid ?? 'mock_partner_1');
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión como negocio para cargar datos')));
      return;
    }
    
    final samplePromos = [
      {
        'partnerId': uid,
        'partnerName': 'Test Partner',
        'title': 'Locro de Papa Especial (Test)',
        'description': '15% de descuento adicional para turistas.',
        'pointsCost': 250,
        'isActive': true,
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': 'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop',
      },
      {
        'partnerId': uid,
        'partnerName': 'Test Partner',
        'title': 'Noche de Canelazos (Test)',
        'description': '2x1 en canelazos presentando el pasaporte digital.',
        'pointsCost': 100,
        'isActive': true,
        'isApproved': false, // Pendiente
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=600&auto=format&fit=crop',
      },
      {
        'partnerId': uid,
        'partnerName': 'Test Partner',
        'title': 'Descuento Expirado (Test)',
        'description': 'Propuesta de 20% descuento.',
        'pointsCost': 300,
        'isActive': false,
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=600&auto=format&fit=crop',
      }
    ];

    for (var promo in samplePromos) {
      await _db.collection('promotions').add(promo);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos de prueba cargados.')));
    }
  }

  Future<void> _deleteAllMyPromos() async {
    final uid = (_auth.currentUser?.uid ?? 'mock_partner_1');
    if (uid == null) return;
    
    final query = await _db.collection('promotions').where('partnerId', isEqualTo: uid).get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promociones borradas.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = (_auth.currentUser?.uid ?? 'mock_partner_1') ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: const Icon(Icons.storefront, color: AppTheme.primary),
        title: const Text(
          'Zizi\'s Tour',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
            onPressed: () => context.push('/negocios/notifications'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('promotions')
            .where('partnerId', isEqualTo: currentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}', style: const TextStyle(color: AppTheme.error)));
          }

          final allPromos = snapshot.data?.docs.map((doc) => PromotionDto.fromJson(doc.data() as Map<String, dynamic>, id: doc.id)).toList() ?? [];
          
          final activas = allPromos.where((p) => p.isApproved == true && p.isActive == true).toList();
          final pendientes = allPromos.where((p) => p.isApproved == false && p.isActive == true).toList();
          final expiradas = allPromos.where((p) => p.isActive == false).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botones temporales de debug
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.tertiaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.tertiary),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Herramientas de Prueba (Borrar luego)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.tertiary)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _loadTestData,
                                    icon: const Icon(Icons.download),
                                    label: const Text('Cargar', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _deleteAllMyPromos,
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Borrar', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Text(
                        'Promociones y Ofertas',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Administra tus campañas, revisa las promociones activas y realiza un seguimiento para atraer más turistas a tu negocio.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/negocios/create-promo'),
                          icon: const Icon(Icons.add, color: AppTheme.onPrimary),
                          label: const Text('Crear Nueva Promoción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildQuickStats(activas.length, pendientes.length),
                      const SizedBox(height: 32),
                      _buildTabs(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 500, // Fijamos un alto para el TabBarView
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPromoList(activas, 'No tienes promociones activas. Crea una nueva oferta para atraer clientes.'),
                            _buildPromoList(pendientes, 'No tienes promociones en estado de revisión (pendientes).'),
                            _buildPromoList(expiradas, 'No hay promociones expiradas o inactivas.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60), // padding for fab
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildPromoList(List<PromotionDto> promos, String emptyMessage) {
    if (promos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(emptyMessage, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: promos.length,
      itemBuilder: (context, index) {
        final promo = promos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildPromoCard(context, promo: promo),
        );
      },
    );
  }

  Widget _buildQuickStats(int activas, int pendientes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 32) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'PROMOS ACTIVAS',
              value: '\$activas',
              icon: Icons.local_activity_outlined,
              width: itemWidth,
            ),
            _buildStatCard(
              title: 'EN REVISIÓN',
              value: '\$pendientes',
              icon: Icons.assignment_outlined,
              width: itemWidth,
            ),
            _buildStatCard(
              title: 'ALCANCE DE CAMPAÑA',
              value: '+24%',
              subtitle: 'visibilidad simulada',
              icon: Icons.trending_up,
              isHighlight: true,
              width: itemWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    bool isHighlight = false,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFFFDBD0) : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(39, 101, 124, isHighlight ? 0 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isHighlight ? AppTheme.primary : AppTheme.secondary,
            size: 24,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppTheme.primary : AppTheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppTheme.onSurface : AppTheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.outlineVariant, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.onSurfaceVariant,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'Aprobadas'),
          Tab(text: 'Pendientes'),
          Tab(text: 'Expiradas'),
        ],
      ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context, {
    required PromotionDto promo,
  }) {
    String tag = 'PENDIENTE';
    Color tagColor = const Color(0xFFFFF3E0);
    Color tagTextColor = const Color(0xFFFF9800);
    IconData tagIcon = Icons.schedule;
    
    if (!promo.isActive) {
      tag = 'INACTIVA';
      tagColor = const Color(0xFFFFEBEE);
      tagTextColor = const Color(0xFFF44336);
      tagIcon = Icons.cancel;
    } else if (promo.isApproved) {
      tag = 'ACTIVA';
      tagColor = const Color(0xFFC8F6D6);
      tagTextColor = const Color(0xFF06D6A0);
      tagIcon = Icons.check_circle_outline;
    }

    // Default image if empty
    final imageUrl = promo.imageUrl.isNotEmpty ? promo.imageUrl : 'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop';
    final dateBadge = DateFormat('dd MMM').format(promo.createdAt ?? DateTime.now());

    return GestureDetector(
      onTap: () {
        context.push('/negocios/promo-detail', extra: {
          'title': promo.title,
          'description': promo.description,
          'imageUrl': imageUrl,
          'tag': tag,
          'stats': '\${promo.pointsCost} Pts • \$dateBadge',
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(39, 101, 124, 0.08),
              blurRadius: 16,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tagIcon, size: 14, color: tagTextColor),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: tagTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                      const Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '\${promo.pointsCost} Pts',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.calendar_today, size: 16, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        dateBadge,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
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
}
