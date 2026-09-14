import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';

class NegocioEditProfileScreen extends StatefulWidget {
  const NegocioEditProfileScreen({super.key});

  @override
  State<NegocioEditProfileScreen> createState() => _NegocioEditProfileScreenState();
}

class _NegocioEditProfileScreenState extends State<NegocioEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController(text: 'Restaurante Vista Hermosa');
  String _selectedCategory = 'Restaurante';
  final _addressController = TextEditingController(text: 'Centro Histórico, Quito');
  final _phoneController = TextEditingController(text: '+593 98 765 4321');
  final _descriptionController = TextEditingController(text: 'El mejor lugar para disfrutar de la comida local con una vista increíble del Panecillo.');

  File? _imageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Editar Perfil del Negocio',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              _buildTextField('Nombre del Negocio', _nameController, Icons.storefront),
              const SizedBox(height: 16),
              
              const Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                    items: ['Restaurante', 'Negocio Local'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(Icons.category, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildTextField('Dirección', _addressController, Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField('Teléfono', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField('Descripción', _descriptionController, Icons.description, maxLines: 3),
              const SizedBox(height: 40),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              image: _imageFile != null
                  ? DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=200&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
              border: Border.all(color: AppTheme.primary, width: 3),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 3),
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.onPrimary, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppTheme.secondary) : null,
            filled: true,
            fillColor: AppTheme.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil del negocio actualizado')),
          );
          context.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
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
    );
  }
}
