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

  void _showAddEditCollectionDialog([DocumentSnapshot? doc]) {
    final nameCtrl = TextEditingController(text: doc?.id ?? '');
    final descCtrl = TextEditingController(text: doc?['description'] ?? '');
    File? imageFile;
    final existingImageUrl = doc?['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          title: Text(doc == null ? 'Nueva Colección' : 'Editar Colección', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre de la Colección / Tour'),
                  enabled: doc == null, // Can't change ID if editing
                ),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                
                String finalImageUrl = existingImageUrl.isEmpty ? 'https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3' : existingImageUrl;
                
                final Map<String, dynamic> data = {
                  'name': name,
                  'description': descCtrl.text.trim(),
                  'imageUrl': finalImageUrl,
                };
                
                if (doc == null) {
                  data['createdAt'] = FieldValue.serverTimestamp();
                }
                
                await _db.collection('tours').doc(name).set(data, SetOptions(merge: true));
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCollection(String id) async {
    // Delete tour document
    await _db.collection('tours').doc(id).delete();
    // Delete all stickers inside it
    final stickers = await _db.collection('stickers').where('collection', isEqualTo: id).get();
    for (var doc in stickers.docs) {
      await doc.reference.delete();
    }
    // Delete all multimedia inside it
    final resources = await _db.collection('tourist_resources').where('tourName', isEqualTo: id).get();
    for (var doc in resources.docs) {
      await doc.reference.delete();
    }
  }

  void _deleteAllStickersAndCollections() async {
    final docs = await _db.collection('stickers').get();
    for (var doc in docs.docs) {
      await doc.reference.delete();
    }
    final resources = await _db.collection('tourist_resources').get();
    for (var doc in resources.docs) {
      await doc.reference.delete();
    }
    final cols = await _db.collection('tours').get();
    for (var doc in cols.docs) {
      await doc.reference.delete();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tours, multimedia y cromos fueron eliminados')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colecciones de Cromos'),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primary), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Borrar todos'),
                  content: const Text('¿Estás seguro de que deseas eliminar TODAS las colecciones y cromos?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteAllStickersAndCollections();
                      },
                      child: const Text('Eliminar Todo', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Borrar todos',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCollectionDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_photo_alternate, color: AppTheme.onPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('tours').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No hay colecciones creadas. Usa el botón mágico o crea una.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return _buildCollectionCard(doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildCollectionCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final collectionName = doc.id;
    return FutureBuilder<AggregateQuerySnapshot>(
      future: _db.collection('stickers').where('collection', isEqualTo: collectionName).count().get(),
      builder: (context, countSnapshot) {
        final count = countSnapshot.data?.count ?? 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => _StickerListScreen(collectionName: collectionName)),
              );
            },
            child: SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    data['imageUrl'] ?? data['image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? data['title'] ?? collectionName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          '$count cromos en esta colección',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (val) {
                        if (val == 'edit') _showAddEditCollectionDialog(doc);
                        if (val == 'delete') _deleteCollection(doc.id);
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StickerListScreen extends StatefulWidget {
  final String collectionName;
  const _StickerListScreen({required this.collectionName});

  @override
  State<_StickerListScreen> createState() => _StickerListScreenState();
}

class _StickerListScreenState extends State<_StickerListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _showAddEditDialog([DocumentSnapshot? doc]) {
    final nameCtrl = TextEditingController(text: doc?['name'] ?? '');
    final descCtrl = TextEditingController(text: doc?['description'] ?? '');
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
                  'collection': widget.collectionName,
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
        title: Text('Cromos - ${widget.collectionName}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: AppTheme.onPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('stickers').where('collection', isEqualTo: widget.collectionName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No hay cromos en esta colección.'));
          
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
                child: InkWell(
                  onTap: () => _showAddEditDialog(doc),
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