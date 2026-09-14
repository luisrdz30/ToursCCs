import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    setState(() {
      _dashboardFuture = () async {
        final db = FirebaseFirestore.instance;
        final usersSnap = await db.collection('users').where('role', isEqualTo: 'tourist').count().get();
        final tripsSnap = await db.collection('trips').where('status', isEqualTo: 'Completed').count().get();
        
        return AdminDashboardDto(
          totalUsers: usersSnap.count ?? 0,
          globalPointsRedeemed: 15400, // Mock for now
          totalToursCompleted: tripsSnap.count ?? 0,
          activeAlerts: 1, // Mock
        );
      }();
    });
  }

  void _onExport() async {
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
          children: const [
            Text('Se ha enviado el reporte detallado en formato CSV y PDF a tu correo de administrador.', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
            SizedBox(height: 16),
            Text('Resumen:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Usuarios Totales: 1,245\n• Ingresos Mensuales: \$12,450\n• Tours Activos: 8\n• Tasa de Aprobación QR: 98%'),
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
                  _loadDashboardData(); // Recargar datos si es necesario (el backend puede aceptar un query param)
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
                  return Center(
                    child: Text('Error al cargar datos: \${snapshot.error}', style: const TextStyle(color: AppTheme.error)),
                  );
                } else if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final data = snapshot.data!;
                return Column(
                  children: [
                    _buildMetricCard(
                      title: 'Puntos Canjeados (Global)',
                      value: '\${data.globalPointsRedeemed}',
                      trend: 'Actualizado ahora',
                      icon: Icons.stars,
                      isPositive: true,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      title: 'Tours Completados',
                      value: '\${data.totalToursCompleted}',
                      trend: 'Actualizado ahora',
                      icon: Icons.explore,
                      isPositive: true,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      title: 'Usuarios Totales',
                      value: '\${data.totalUsers}',
                      trend: 'Actualizado ahora',
                      icon: Icons.people,
                      isPositive: null,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      title: 'Alertas del Sistema',
                      value: '\${data.activeAlerts}',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Iniciando carga de datos...')),
                  );
                  final seeder = DatabaseSeeder();
                  await seeder.seedAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Datos cargados exitosamente')),
                    );
                  }
                },
                icon: const Icon(Icons.cloud_upload, color: AppTheme.onPrimary),
                label: const Text('Cargar Datos Iniciales a Firebase', style: TextStyle(color: AppTheme.onPrimary, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
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
          icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.primary),
          onPressed: () {
            context.push('/admin/notifications');
          },
        ),
      ],
    );
  }

  Widget _buildFilterButton(String text, IconData icon, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryContainer : AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isPrimary ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant,
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
    Color trendColor;
    if (isPositive == true) {
      trendColor = Colors.green;
    } else if (isPositive == false) {
      trendColor = AppTheme.error;
    } else {
      trendColor = AppTheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(39, 101, 124, 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isPositive != null)
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: trendColor,
                    ),
                  if (isPositive != null) const SizedBox(width: 4),
                  Text(
                    trend,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            icon,
            size: 80,
            color: AppTheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
