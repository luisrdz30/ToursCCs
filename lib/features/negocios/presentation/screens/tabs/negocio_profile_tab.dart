import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/services/firebase_auth_service.dart';

class NegocioProfileTab extends StatefulWidget {
  const NegocioProfileTab({super.key});

  @override
  State<NegocioProfileTab> createState() => _NegocioProfileTabState();
}

class _NegocioProfileTabState extends State<NegocioProfileTab> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _hoursController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCategory = 'Restaurante';

  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final uid = (_auth.currentUser?.uid ?? 'mock_partner_1');
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _descController.text = data['description'] ?? '';
            _hoursController.text = data['hours'] ?? '';
            _locationController.text = data['location'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _selectedCategory = data['category'] ?? 'Restaurante';
            _menuItems = data['menuItems'] ?? [];
          });
        }
      }
    } catch (e) {
      print('Error fetching profile: \$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final uid = (_auth.currentUser?.uid ?? 'mock_partner_1');
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      await _db.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'hours': _hoursController.text.trim(),
        'location': _locationController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'menuItems': _menuItems,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: \$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _hoursController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showEditMenuItemDialog({int? index}) {
    final isEditing = index != null;
    final initialData = isEditing ? _menuItems[index] : {};
    
    final titleCtrl = TextEditingController(text: initialData['name']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: initialData['price']?.toString() ?? '');
    final descCtrl = TextEditingController(text: initialData['description']?.toString() ?? '');
    final imageCtrl = TextEditingController(text: initialData['imageUrl']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Editar Item' : 'Nuevo Item',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.error),
                        onPressed: () {
                          setState(() {
                            _menuItems.removeAt(index);
                          });
                          _saveProfile();
                          context.pop();
                        },
                      )
                  ],
                ),
                const SizedBox(height: 24),
                _buildDialogField('Nombre del plato / producto', titleCtrl, Icons.fastfood_outlined),
                const SizedBox(height: 16),
                _buildDialogField('Precio', priceCtrl, Icons.attach_money, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDialogField('Descripción', descCtrl, Icons.description_outlined, maxLines: 3),
                const SizedBox(height: 16),
                _buildDialogField('URL de Imagen', imageCtrl, Icons.image_outlined),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = titleCtrl.text.trim();
                      final price = double.tryParse(priceCtrl.text) ?? 0.0;
                      final desc = descCtrl.text.trim();
                      final image = imageCtrl.text.trim();
                      
                      if (name.isEmpty) return;

                      final newItem = {
                        'name': name,
                        'description': desc,
                        'price': price,
                        'imageUrl': image,
                      };

                      setState(() {
                        if (isEditing) {
                          _menuItems[index] = newItem;
                        } else {
                          _menuItems.add(newItem);
                        }
                      });
                      
                      _saveProfile();
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: AppTheme.secondary) : null,
        filled: true,
        fillColor: AppTheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: const Icon(Icons.storefront, color: AppTheme.primary),
        title: const Text(
          'Partner Portal',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Perfil del Negocio',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Información General',
                    children: [
                      _buildField('Nombre del Negocio', _nameController, Icons.storefront),
                      const SizedBox(height: 16),
                      _buildField('Teléfono', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildField('Descripción', _descController, null, maxLines: 4),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Logística',
                    children: [
                      _buildField('Horario', _hoursController, Icons.access_time),
                      const SizedBox(height: 16),
                      _buildField('Ubicación', _locationController, Icons.location_on_outlined),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildMenuSection(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuthService().signOut();
                        if (mounted) {
                          context.go('/');
                        }
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
                  const SizedBox(height: 80), // padding for bottom nav
                ],
              ),
            ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData? icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppTheme.secondary, size: 20) : null,
            filled: true,
            fillColor: AppTheme.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría Principal',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: ['Restaurante', 'Hotel', 'Tour', 'Negocio Local'].contains(_selectedCategory) ? _selectedCategory : 'Negocio Local',
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
              items: ['Restaurante', 'Hotel', 'Tour', 'Negocio Local'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.category, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(value, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Menú / Catálogo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showEditMenuItemDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
            )
          ],
        ),
        const SizedBox(height: 16),
        if (_menuItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outlineVariant, style: BorderStyle.solid),
            ),
            child: const Text('No hay items en el menú. Agrega productos para que los turistas los vean.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.onSurfaceVariant)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildMenuCard(item, index);
            },
          )
      ],
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item, int index) {
    final imageStr = item['imageUrl']?.toString() ?? '';
    final imageUrl = imageStr.isNotEmpty ? imageStr : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(39, 101, 124, 0.05), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditMenuItemDialog(index: index),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${item["price"]}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'] ?? '',
                        style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
