import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/network/api_client.dart';

import '../../../../../core/services/firebase_auth_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _docController = TextEditingController();
  String _selectedRole = 'Turista';
  String? _selectedCountry;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _docController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete el nombre y correo')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = FirebaseAuthService();
      
      // Role mapping
      String roleCode = 'tourist';
      if (_selectedRole == 'Chofer') roleCode = 'driver';
      if (_selectedRole == 'Negocio') roleCode = 'partner';
      if (_selectedRole == 'Administrador') roleCode = 'admin';

      await authService.createUserFromAdmin(
        email: _emailController.text.trim(),
        role: roleCode,
        name: _nameController.text.trim(),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Registro Exitoso'),
          content: Text(
            'Usuario ${_emailController.text.trim()} creado exitosamente en Firebase.\n\nSe ha enviado un correo electrónico automático a esa dirección con un enlace para que el usuario establezca su propia contraseña segura.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop(); // Go back to previous screen
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
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
            icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.primary), onPressed: () => context.push('/admin/notifications'),
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
              'Registro de Nuevo\nUsuario',
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
              'Complete los siguientes campos con la información oficial para generar su perfil en el ecosistema Zizi\'s Tour.',
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
                          'Una vez que completes el registro, generaremos una contraseña segura que deberás compartir con el usuario.',
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
                  _buildFieldLabel('Nombre Completo / Empresa'),
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
                  
                  _buildFieldLabel('Nacionalidad / Origen'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCountry,
                        hint: Row(
                          children: const [
                            Icon(Icons.public, color: AppTheme.primary, size: 20),
                            SizedBox(width: 12),
                            Text('Selecciona país o ciudad', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                          ],
                        ),
                        items: ['Argentina', 'Brasil', 'Chile', 'Colombia', 'España', 'Estados Unidos', 'México', 'Perú']
                            .map((country) => DropdownMenuItem(
                                  value: country,
                                  child: Text(country),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCountry = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFieldLabel('Pasaporte / DNI / RUC'),
                  _buildTextField(
                    controller: _docController,
                    hintText: 'Número de documento',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFieldLabel('Perfil Asignado'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedRole,
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                        items: ['Turista', 'Chofer', 'Negocio'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'Turista' ? Icons.person : (value == 'Chofer' ? Icons.directions_car : Icons.storefront),
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  value,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: AppTheme.onPrimary, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Registrar Usuario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
