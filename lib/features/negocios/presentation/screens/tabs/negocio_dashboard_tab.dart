import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/models/business_dashboard_dto.dart';
import '../../../../../core/models/promotion_dto.dart';

class NegocioDashboardTab extends StatefulWidget {
  final Function(int)? onTabChange;

  const NegocioDashboardTab({super.key, this.onTabChange});

  @override
  State<NegocioDashboardTab> createState() => _NegocioDashboardTabState();
}

class _NegocioDashboardTabState extends State<NegocioDashboardTab> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _partnerName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadPartnerName();
  }

  Future<void> _loadPartnerName() async {
    final uid = (_auth.currentUser?.uid ?? 'mock_partner_1');
    if (uid == null) return;
    
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _partnerName = doc.data()?['name'] ?? 'Negocio Aliado';
        });
      }
    } catch (e) {
      // Ignorar
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
        stream: _db.collection('promotions').where('partnerId', isEqualTo: currentUid).snapshots(),
        builder: (context, snapshot) {
          int totalPoints = 0;
          List<PromotionDto> activePromos = [];
          
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            for (var doc in docs) {
              final promo = PromotionDto.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
              if (promo.isActive && promo.isApproved) {
                activePromos.add(promo);
              }
              // Simulamos puntos generados en base al costo de puntos de las promos activas
              if (promo.isActive) {
                totalPoints += (promo.pointsCost * 5); // multiplicador mock
              }
            }
          }

          final dashboardData = BusinessDashboardDto(
            pointsGenerated: totalPoints > 0 ? totalPoints : 1250, // Fallback visual
            growthPercentage: 15.5,
            scansToday: snapshot.hasData ? activePromos.length * 12 : 81, // Fallback visual
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(_partnerName),
                const SizedBox(height: 24),
                _buildActionButtons(context),
                const SizedBox(height: 32),
                _buildPointsCard(dashboardData),
                const SizedBox(height: 16),
                _buildScansCard(context, dashboardData),
                const SizedBox(height: 40),
                _buildEventsHeader(),
                const SizedBox(height: 16),
                if (activePromos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No tienes promociones activas. ¡Crea una ahora!', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                    ),
                  )
                else
                  ...activePromos.take(3).map((promo) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildEventCard(
                        title: promo.title,
                        tag: 'Activa',
                        description: promo.description,
                        stats: '\${promo.pointsCost} Pts',
                        imageUrl: promo.imageUrl.isNotEmpty ? promo.imageUrl : 'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop',
                      ),
                    );
                  }),
                const SizedBox(height: 80),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTitleRow(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RESUMEN DE HOY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              if (widget.onTabChange != null) {
                widget.onTabChange!(2);
              } else {
                context.push('/negocios/edit-profile');
              }
            },
            borderRadius: BorderRadius.circular(32),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit, size: 16, color: AppTheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () {
              context.push('/negocios/create-promo');
            },
            borderRadius: BorderRadius.circular(32),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryContainer, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, size: 16, color: AppTheme.onPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Crear Promo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onPrimary,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(BusinessDashboardDto data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(39, 101, 124, 0.08), blurRadius: 16, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Puntos Generados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\${data.pointsGenerated}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(data.growthPercentage >= 0 ? Icons.trending_up : Icons.trending_down, 
                  color: data.growthPercentage >= 0 ? Colors.green : Colors.red, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '\${data.growthPercentage >= 0 ? '+' : ''}\${data.growthPercentage}% vs la semana pasada',
                  style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScansCard(BuildContext context, BusinessDashboardDto data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(39, 101, 124, 0.08), blurRadius: 16, offset: Offset(0, 8))
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: AppTheme.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Escaneos de Hoy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '\${data.scansToday}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: -2,
                ),
              ),
              const Text(
                'Turistas únicos',
                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildAvatarStack(),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '+\${data.scansToday}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                context.push('/negocios/scan');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner, color: AppTheme.onPrimaryContainer, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 80,
      height: 32,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _buildAvatar('https://i.pravatar.cc/100?img=1'),
          ),
          Positioned(
            left: 24,
            child: _buildAvatar('https://i.pravatar.cc/100?img=2'),
          ),
          Positioned(
            left: 48,
            child: _buildAvatar('https://i.pravatar.cc/100?img=3'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.surfaceContainerLowest, width: 2),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEventsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.event_available, color: AppTheme.secondary),
            SizedBox(width: 8),
            Text(
              'Próximos Eventos Activos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            if (widget.onTabChange != null) {
              widget.onTabChange!(1); // Navigate to Promos tab
            }
          },
          child: const Text(
            'Ver Todos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String tag,
    required String description,
    required String stats,
    required String imageUrl,
    bool isUpcoming = false,
  }) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () {
            context.push('/negocios/promo-detail', extra: {
              'title': title,
              'description': description,
              'imageUrl': imageUrl,
              'tag': tag,
              'stats': stats,
            });
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(39, 101, 124, 0.08), blurRadius: 16, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUpcoming ? AppTheme.surfaceContainer : AppTheme.secondaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUpcoming ? AppTheme.onSurfaceVariant : AppTheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
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
                          Icon(
                            isUpcoming ? Icons.schedule : Icons.people_outline,
                            size: 16,
                            color: AppTheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            stats,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondary,
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
    );
  }
}
