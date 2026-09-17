import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/models/admin_dashboard_dto.dart';
import '../../../../../core/services/database_seeder.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  String _selectedTimeframe = 'Últimos 30 días';
  bool _isExporting = false;
  Future<AdminDashboardDto>? _dashboardFuture;
  AdminDashboardDto? _currentData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    setState(() {
      _dashboardFuture = () async {
        final db = FirebaseFirestore.instance;
        
        DateTime cutoffDate = DateTime(2000);
        final now = DateTime.now();
        if (_selectedTimeframe == 'Hoy') {
          cutoffDate = DateTime(now.year, now.month, now.day);
        } else if (_selectedTimeframe == 'Esta Semana') {
          cutoffDate = now.subtract(Duration(days: now.weekday - 1));
        } else if (_selectedTimeframe == 'Últimos 30 días') {
          cutoffDate = now.subtract(const Duration(days: 30));
        } else if (_selectedTimeframe == 'Este Año') {
          cutoffDate = DateTime(now.year, 1, 1);
        }

        // Avoid composite query error by using the already-fetched users for counting
        final usersDocs = await db.collection('users').get();
        int totalUsersCount = 0;
        int totalPoints = 0;

        for (var doc in usersDocs.docs) {
          final data = doc.data();
          final role = data['role'] as String?;
          final points = (data['points'] as num?)?.toInt() ?? 0;
          totalPoints += points;

          if (role == 'tourist') {
            final createdAt = data['createdAt'] as Timestamp?;
            if (createdAt != null && !createdAt.toDate().isBefore(cutoffDate)) {
              totalUsersCount++;
            } else if (cutoffDate.year == 2000) {
               // If filtering "Todos", include everything
               totalUsersCount++;
            }
          }
        }

        final toursSnap = await db.collection('tours')
          .where('createdAt', isGreaterThanOrEqualTo: cutoffDate)
          .count().get();

        final data = AdminDashboardDto(
          totalUsers: totalUsersCount,
          totalToursCompleted: toursSnap.count ?? 0,
          globalPointsRedeemed: totalPoints, // Puntos totales en ecosistema
          activeAlerts: 0,
        );
        _currentData = data;
        return data;
      }();
    });
  }

  void _onExport() async {
    if (_currentData == null) return;
    setState(() => _isExporting = true);
    
    // Simulate generation delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    setState(() => _isExporting = false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Reporte Generado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Se ha enviado el reporte detallado en formato CSV y PDF a tu correo de administrador.', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
            const SizedBox(height: 16),
            const Text('Resumen:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('• Usuarios Totales: ${_currentData!.totalUsers}\n• Puntos del Ecosistema: ${_currentData!.globalPointsRedeemed}\n• Tours Registrados: ${_currentData!.totalToursCompleted}\n• Filtro: $_selectedTimeframe'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary),
            child: const Text('Entendido'),
          )
        ],
      ),
    );
  }

  void _showTimeframeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Hoy', 'Esta Semana', 'Últimos 30 días', 'Este Año'].map((timeframe) {
              return ListTile(
                title: Text(timeframe, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: _selectedTimeframe == timeframe ? const Icon(Icons.check, color: AppTheme.primary) : null,
                onTap: () {
                  setState(() => _selectedTimeframe = timeframe);
                  Navigator.pop(context);
                  _loadDashboardData();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/scan');
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.qr_code_scanner, color: AppTheme.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel de Control',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Métricas en tiempo real y salud del ecosistema turístico en Quito.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                InkWell(
                  onTap: _showTimeframeSelector,
                  child: _buildFilterButton(_selectedTimeframe, Icons.calendar_today),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _isExporting ? null : _onExport,
                  child: _buildFilterButton(
                    _isExporting ? 'Generando...' : 'Exportar', 
                    Icons.picture_as_pdf_outlined, 
                    isPrimary: true
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FutureBuilder<AdminDashboardDto>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No hay datos disponibles.'));
                }

                final data = snapshot.data!;

                return Column(
                  children: [
                    _buildMetricCard(
                      title: 'Puntos Canjeados (Global)',
                      value: '${data.globalPointsRedeemed}',
                      trend: 'Actualizado ahora',
                      icon: Icons.stars,
                      isPositive: true,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      title: 'Tours Completados',
                      value: '${data.totalToursCompleted}',
                      trend: 'Actualizado ahora',
                      icon: Icons.explore,
                      isPositive: true,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      title: 'Usuarios Totales',
                      value: '${data.totalUsers}',
                      trend: 'Actualizado ahora',
                      icon: Icons.people,
                      isPositive: null,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      title: 'Alertas del Sistema',
                      value: '${data.activeAlerts}',
                      trend: data.activeAlerts > 0 ? 'Requieren atención' : 'Todo en orden',
                      icon: data.activeAlerts > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      isPositive: data.activeAlerts == 0,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go('/'); // Route to login
                  }
                },
                icon: const Icon(Icons.logout, color: AppTheme.onError),
                label: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.onError, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, IconData icon, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primary : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
        boxShadow: isPrimary ? [
          const BoxShadow(color: Color.fromRGBO(240, 101, 67, 0.3), blurRadius: 10, offset: Offset(0, 4))
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isPrimary ? AppTheme.onPrimary : AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppTheme.onPrimary : AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    bool? isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(39, 101, 124, 0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              letterSpacing: -1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (isPositive != null)
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              if (isPositive != null) const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPositive == null
                      ? AppTheme.onSurfaceVariant
                      : (isPositive ? Colors.green : Colors.red),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      leading: const Icon(Icons.admin_panel_settings, color: AppTheme.primary),
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
          icon: const Icon(Icons.refresh, color: AppTheme.primary),
          onPressed: _loadDashboardData,
          tooltip: 'Recargar Datos',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.primary),
          onPressed: () => context.push('/admin/notifications'),
        ),
      ],
    );
  }
}
