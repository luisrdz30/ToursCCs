import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/database_seeder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedLanguage = 'en';
  bool isOfflineMode = false;
  bool isLoading = false;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final sessionStartStr = prefs.getString('session_start');
      final role = prefs.getString('user_role') ?? await _authService.getUserRole(user.uid);
      
      if (sessionStartStr != null) {
        final sessionStart = DateTime.parse(sessionStartStr);
        final elapsed = DateTime.now().difference(sessionStart);
        
        bool isExpired = false;
        if (role == 'admin' && elapsed.inHours >= 2) {
          isExpired = true;
        } else if ((role == 'driver' || role == 'business' || role == 'partner') && elapsed.inHours >= 24) {
          isExpired = true;
        } else if (role == 'tourist' && elapsed.inDays >= 30) {
          isExpired = true;
        }
        
        if (isExpired) {
          await FirebaseAuth.instance.signOut();
          await prefs.remove('session_start');
          await prefs.remove('user_role');
        } else {
          _navigateToRole(role);
        }
      } else {
        // No session tracked, let's track it now
        await prefs.setString('session_start', DateTime.now().toIso8601String());
        await prefs.setString('user_role', role);
        _navigateToRole(role);
      }
    }
  }

  void _navigateToRole(String role) {
    if (mounted) {
      if (role == 'tourist') {
        context.go('/turista');
      } else if (role == 'driver') {
        context.go('/chofer');
      } else if (role == 'business' || role == 'partner') {
        context.go('/negocios');
      } else if (role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/bridge');
      }
    }
  }

  Future<void> _onStartExploring() async {
    final emailText = _idController.text.trim();
    final passwordText = _passwordController.text.trim();

    if (emailText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu email.'),
          backgroundColor: AppTheme.error,
        )
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (passwordText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa tu contraseña.'),
            backgroundColor: AppTheme.error,
          )
        );
        setState(() { isLoading = false; });
        return;
      }

      final userCred = await _authService.signIn(emailText, passwordText);
      if (userCred != null && userCred.user != null) {
        final role = await _authService.getUserRole(userCred.user!.uid);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_start', DateTime.now().toIso8601String());
        await prefs.setString('user_role', role);
        
        _navigateToRole(role);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión. Revisa tus credenciales.'),
            backgroundColor: AppTheme.error,
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ambient Background Elements
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB59D).withOpacity(0.2), // primary-fixed-dim/20
              ),
            ).blurred(80),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF59D5FB).withOpacity(0.2), // tertiary-fixed-dim/20
              ),
            ).blurred(100),
          ),
          
          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mascot and Titles
                    Container(
                      width: 128,
                      height: 128,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Image.asset('assets/images/mascota.png', fit: BoxFit.contain),
                    ),
                    Text(
                      'Bienvenido a Zizi\'s Tour',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tu acompañante inteligente para turismo en Quito, Ecuador.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Glassmorphism Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF261814).withOpacity(0.05),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Top Gradient Border
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppTheme.primary, AppTheme.tertiary, AppTheme.primaryContainer],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Language Selector
                                    _buildLabel(Icons.language, 'Idioma'),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surface.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppTheme.outlineVariant),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedLanguage,
                                          isExpanded: true,
                                          icon: const Icon(Icons.expand_more, color: AppTheme.onSurfaceVariant),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedLanguage = newValue;
                                              });
                                            }
                                          },
                                          items: const [
                                            DropdownMenuItem(value: 'en', child: Text('English (US)')),
                                            DropdownMenuItem(value: 'es', child: Text('Español (ES)')),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // ID Input
                                    _buildLabel(Icons.badge_outlined, 'Ingresa tu número de identificación'),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _idController,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      decoration: InputDecoration(
                                        hintText: 'ejemplo@zizistour.com',
                                        hintStyle: const TextStyle(color: AppTheme.outline),
                                        filled: true,
                                        fillColor: AppTheme.surface.withOpacity(0.8),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
                                        ),
                                      ),
                                      onSubmitted: (_) => _onStartExploring(),
                                    ),
                                    // Password Input
                                    const SizedBox(height: 16),
                                    _buildLabel(Icons.lock_outline, 'Contraseña'),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      decoration: InputDecoration(
                                        hintText: 'Tu contraseña',
                                        hintStyle: const TextStyle(color: AppTheme.outline),
                                        filled: true,
                                        fillColor: AppTheme.surface.withOpacity(0.8),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
                                        ),
                                      ),
                                      onSubmitted: (_) => _onStartExploring(),
                                    ),
                                    const SizedBox(height: 24),                                  
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Divider(color: AppTheme.outlineVariant, height: 1),
                                    ),
                                    
                                    // Offline Mode Toggle
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Modo sin conexión',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: isOfflineMode ? AppTheme.primary : AppTheme.onSurface,
                                              ),
                                            ),
                                            Text(
                                              'Descarga datos antes de viajar',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontSize: 14,
                                                color: AppTheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Switch(
                                          value: isOfflineMode,
                                          onChanged: (val) {
                                            setState(() {
                                              isOfflineMode = val;
                                            });
                                          },
                                          activeColor: Colors.white,
                                          activeTrackColor: AppTheme.primary,
                                          inactiveTrackColor: const Color(0xFFFDE3DB),
                                          inactiveThumbColor: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Primary Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _onStartExploring,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: AppTheme.onPrimary,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          elevation: 8,
                                          shadowColor: AppTheme.primaryContainer.withOpacity(0.4),
                                        ),
                                        child: isLoading 
                                          ? const SizedBox(
                                              height: 20, 
                                              width: 20, 
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Comenzar Aventura',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: AppTheme.onPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(Icons.arrow_forward),
                                              ],
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: () async {
                                        try {
                                          setState(() => isLoading = true);
                                          final seeder = DatabaseSeeder();
                                          await seeder.createTestAccounts();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuentas y Datos generados! (pass: 123456)')));
                                          }
                                        } catch(e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        } finally {
                                          if (mounted) setState(() => isLoading = false);
                                        }
                                      },
                                      icon: const Icon(Icons.build, color: AppTheme.secondary),
                                      label: const Text('Crear/Arreglar Cuentas de Prueba', style: TextStyle(color: AppTheme.secondary)),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    // Support Link
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline, size: 18, color: AppTheme.secondary),
                      label: Text(
                        '¿Necesitas ayuda para entrar?',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// Extension to easily blur widgets for the ambient background
extension BlurExtension on Widget {
  Widget blurred(double sigma) {
    return ImageFilterWidget(sigma: sigma, child: this);
  }
}

class ImageFilterWidget extends StatelessWidget {
  final double sigma;
  final Widget child;
  const ImageFilterWidget({super.key, required this.sigma, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }
}
