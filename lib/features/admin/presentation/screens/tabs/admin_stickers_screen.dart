import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_theme.dart';

class AdminStickersScreen extends StatefulWidget {
  const AdminStickersScreen({super.key});

  @override
  State<AdminStickersScreen> createState() => _AdminStickersScreenState();
}

class _AdminStickersScreenState extends State<AdminStickersScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _showAddEditDialog([DocumentSnapshot? doc]) {
    final nameCtrl = TextEditingController(text: doc?['name'] ?? '');
    final descCtrl = TextEditingController(text: doc?['description'] ?? '');
    final collectionCtrl = TextEditingController(text: doc?['collection'] ?? '');
    String rarity = doc?['rarity'] ?? 'Común';
    bool isActive = doc?['isActive'] ?? true;
    File? imageFile;
    final existingImageUrl = doc?['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          title: Text(doc == null ? 'Nuevo Cromo' : 'Editar Cromo', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() {
                        imageFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      image: imageFile != null
                          ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                          : (existingImageUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(existingImageUrl), fit: BoxFit.cover)
                              : null),
                    ),
                    child: (imageFile == null && existingImageUrl.isEmpty)
                        ? const Center(child: Icon(Icons.add_photo_alternate, color: AppTheme.onSurfaceVariant))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del Cromo')),
                const SizedBox(height: 8),
                TextField(controller: collectionCtrl, decoration: const InputDecoration(labelText: 'Colección / Tour (Ej. Centro Histórico)')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción / Historia'), maxLines: 2),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: rarity,
                  decoration: const InputDecoration(labelText: 'Rareza'),
                  items: ['Común', 'Raro', 'Épico', 'Legendario'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setDialogState(() => rarity = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Habilitado'),
                    Switch(value: isActive, onChanged: (val) => setDialogState(() => isActive = val)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                
                String finalImageUrl = existingImageUrl.isEmpty ? 'https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3' : existingImageUrl;
                
                final data = {
                  'name': nameCtrl.text.trim(),
                  'collection': collectionCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'rarity': rarity,
                  'isActive': isActive,
                  'imageUrl': finalImageUrl,
                };
                
                if (doc == null) {
                  await _db.collection('stickers').add({...data, 'createdAt': FieldValue.serverTimestamp()});
                } else {
                  await _db.collection('stickers').doc(doc.id).update(data);
                }
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSticker(String id) async {
    await _db.collection('stickers').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Álbum de Cromos'),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primary), onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: AppTheme.onPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('stickers').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No hay cromos creados.'));
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Image.network(
                            doc['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(doc['rarity'], style: TextStyle(fontSize: 12, color: _getRarityColor(doc['rarity']))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 4, right: 4,
                      child: PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'edit') _showAddEditDialog(doc);
                          if (val == 'delete') _deleteSticker(doc.id);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'edit', child: Text('Editar')),
                          const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                    if (!(doc['isActive'] ?? true))
                      Positioned(
                        top: 4, left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Inactivo', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Raro': return Colors.blue;
      case 'Épico': return Colors.purple;
      case 'Legendario': return Colors.orange;
      default: return Colors.grey;
    }
  }
}