import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';

class NegocioCreatePromoScreen extends StatefulWidget {
  const NegocioCreatePromoScreen({super.key});

  @override
  State<NegocioCreatePromoScreen> createState() => _NegocioCreatePromoScreenState();
}

class _NegocioCreatePromoScreenState extends State<NegocioCreatePromoScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _descController = TextEditingController();
  final _offerController = TextEditingController();
  
  File? _imageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descController.dispose();
    _offerController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              'Partner Portal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        centerTitle: true,
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
            const Text(
              'Nueva Solicitud de\nPromoción',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: -1,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Crea un evento o promoción para atraer a más viajeros.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.onSurfaceVariant,
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
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Imagen de la Promo'),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        image: _imageFile != null
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo, color: AppTheme.primary, size: 40),
                                SizedBox(height: 8),
                                Text('Toca para subir una foto', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFieldLabel('Nombre del Evento'),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Ej: Noche de Tapas y Flamenco',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFieldLabel('Fecha'),
                  _buildTextField(
                    controller: _dateController,
                    hintText: 'dd/mm/aaaa',
                    prefixIcon: Icons.calendar_today,
                    suffixIcon: Icons.calendar_month,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFieldLabel('Descripción del Evento'),
                  _buildTextField(
                    controller: _descController,
                    hintText: 'Describe los detalles de la experiencia...',
                    maxLines: 4,
                    fillColor: AppTheme.surfaceContainer,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFieldLabel('Oferta Especial'),
                  _buildTextField(
                    controller: _offerController,
                    hintText: 'Ej: 20% discount',
                    prefixIcon: Icons.local_offer_outlined,
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info, color: AppTheme.tertiary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Su solicitud será enviada al administrador para revisión. Le notificaremos una vez aprobada.',
                            style: TextStyle(
                              color: AppTheme.onSurface.withOpacity(0.8),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Solicitud enviada para revisión')),
                        );
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainer,
                        foregroundColor: AppTheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Enviar para Aprobación',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send_outlined, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    int maxLines = 1,
    Color fillColor = Colors.transparent,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.5)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.primary, size: 20) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppTheme.onSurfaceVariant, size: 20) : null,
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: fillColor == Colors.transparent ? AppTheme.outlineVariant : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
