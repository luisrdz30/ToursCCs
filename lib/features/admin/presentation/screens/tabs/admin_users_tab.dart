import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _docController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _docController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: const Icon(Icons.menu, color: AppTheme.primary),
        title: const Text(
          'TravelSmart',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.flight_takeoff, color: AppTheme.primary, size: 32),
            const SizedBox(height: 16),
            const Text(
              'Registro de Nuevo\nTurista',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete los siguientes campos con la información oficial del viajero para generar su perfil en el ecosistema TravelSmart AI.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.badge_outlined, color: AppTheme.tertiary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credenciales Seguras',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Una vez que completes el registro, enviaremos tus credenciales de acceso de forma segura a tu correo electrónico. Asegúrate de proporcionar una dirección válida.',
                          style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
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
                  _buildFieldLabel('Nombre Completo'),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Ej. Ana García',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFieldLabel('Correo Electrónico'),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'tu@email.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFieldLabel('Nacionalidad'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Row(
                          children: const [
                            Icon(Icons.public, color: AppTheme.primary, size: 20),
                            SizedBox(width: 12),
                            Text('Selecciona tu país', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                          ],
                        ),
                        items: const [],
                        onChanged: (val) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFieldLabel('Pasaporte / DNI'),
                  _buildTextField(
                    controller: _docController,
                    hintText: 'Número de documento',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.assignment_ind_outlined, color: AppTheme.primary, size: 20),
                            SizedBox(width: 12),
                            Text('Perfil Asignado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const Text(
                          'Turista',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/admin/user-success');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Crear Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Al crear una cuenta, aceptas nuestros\nTérminos de Servicio y Política de\nPrivacidad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.primary, size: 20) : null,
        filled: true,
        fillColor: AppTheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
