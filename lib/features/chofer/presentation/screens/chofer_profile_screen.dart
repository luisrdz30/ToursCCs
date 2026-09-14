import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';

class ChoferProfileScreen extends StatefulWidget {
  const ChoferProfileScreen({super.key});

  @override
  State<ChoferProfileScreen> createState() => _ChoferProfileScreenState();
}

class _ChoferProfileScreenState extends State<ChoferProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 24),
                    _buildForm(),
                    const SizedBox(height: 32),
                    _buildSaveButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Mi Perfil',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 4),
              image: DecorationImage(
                image: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider
                    : const NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDC0A0DhH8OLoBPmHsTJAlS-4kxpiv7HzjURy2986Hh7CAX72U5rYee7fGuQGIXh5LIDoKv2t8wD6ZuVDskw20TOg1xq_YSP0P1z1WOWwKJAMUW7-zqVm0qTgooysMmCjMVI0ibPTzBRaNsJEqlYTXhRNbZV6jtnZmrbUzr-aa8Zq1ylcYHAyhWEqZk8yAKAye5SycVlooVzbj9-Tde-qGoQ36efu4xlPFewVu_jsIQLfCv7PfodJfd2Q',
                      ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: AppTheme.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(label: 'Nombre completo', initialValue: 'Carlos Chofer'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Número de teléfono', initialValue: '+593 99 123 4567', keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField(label: 'Correo electrónico', initialValue: 'carlos@zizistour.com', keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildTextField({required String label, required String initialValue, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cambios guardados con éxito')),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Guardar Cambios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Sign out logic would go here
              context.go('/');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
