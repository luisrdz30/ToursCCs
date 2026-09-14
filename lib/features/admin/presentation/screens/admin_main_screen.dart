import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_promos_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_tours_tab.dart';
import 'tabs/admin_content_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const AdminDashboardTab(),
    const AdminPromosTab(),
    const AdminUsersTab(),
    const AdminToursTab(),
    const AdminContentTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _tabs[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 78, 100, 0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.storefront, 'Negocios'),
            _buildNavItem(1, Icons.local_offer_outlined, 'Promos'),
            _buildNavItem(2, Icons.people_outline, 'Usuarios'),
            _buildNavItem(3, Icons.explore_outlined, 'Tours'),
            _buildNavItem(4, Icons.games_outlined, 'Juegos'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.secondary.withValues(alpha: 0.5),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.secondary.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
