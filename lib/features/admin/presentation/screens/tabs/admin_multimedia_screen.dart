import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../../core/theme/app_theme.dart';

class AdminMultimediaScreen extends StatefulWidget {
  const AdminMultimediaScreen({super.key});

  @override
  State<AdminMultimediaScreen> createState() => _AdminMultimediaScreenState();
}

class _AdminMultimediaScreenState extends State<AdminMultimediaScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _showAddEditTourDialog([DocumentSnapshot? doc]) {
    final nameCtrl = TextEditingController(text: doc?.id ?? '');
    final descCtrl = TextEditingController(text: doc?['description'] ?? '');
    File? imageFile;
    final existingImageUrl = doc?['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          title: Text(doc == null ? 'Nuevo Tour' : 'Editar Tour', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  decoration: const InputDecoration(labelText: 'Nombre del Tour'),
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

  void _deleteTour(String id) async {
    // Delete tour document
    await _db.collection('tours').doc(id).delete();
    // Delete all resources inside it
    final resources = await _db.collection('tourist_resources').where('tourName', isEqualTo: id).get();
    for (var doc in resources.docs) {
      await doc.reference.delete();
    }
    // Delete all stickers inside it
    final stickers = await _db.collection('stickers').where('collection', isEqualTo: id).get();
    for (var doc in stickers.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tours (Multimedia)'),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primary), onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTourDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_photo_alternate, color: AppTheme.onPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('tours').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No hay tours creados. Usa el botón mágico o crea uno.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return _buildTourCard(doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildTourCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final tourName = doc.id;
    return FutureBuilder<AggregateQuerySnapshot>(
      future: _db.collection('culture_multimedia').where('tourId', isEqualTo: tourName).count().get(),
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
                MaterialPageRoute(builder: (context) => _ResourceListScreen(tourName: tourName)),
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
                          data['name'] ?? data['title'] ?? tourName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          '$count elementos multimedia',
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
                        if (val == 'edit') _showAddEditTourDialog(doc);
                        if (val == 'delete') _deleteTour(doc.id);
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

class _ResourceListScreen extends StatefulWidget {
  final String tourName;
  const _ResourceListScreen({required this.tourName});

  @override
  State<_ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<_ResourceListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _showAddEditDialog([DocumentSnapshot? doc]) {
    final titleCtrl = TextEditingController(text: doc?['title'] ?? '');
    final descCtrl = TextEditingController(text: doc?['description'] ?? '');
    final urlCtrl = TextEditingController(text: doc?['url'] ?? '');
    String type = doc?['type'] ?? 'Video';
    bool isActive = doc?['isActive'] ?? true;
    bool isUploading = false;
    double uploadProgress = 0.0;
    File? selectedFile;
    String? selectedFileName;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          title: Text(doc == null ? 'Nuevo Recurso' : 'Editar Recurso', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Tipo de Recurso'),
                  items: ['Video', 'Cómic / Historia', 'Audio'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setDialogState(() => type = val!),
                ),
                const SizedBox(height: 16),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
                const SizedBox(height: 16),
                
                const Text('Archivo Multimedia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary)),
                const SizedBox(height: 8),
                
                if (selectedFileName != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.file_present, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(selectedFileName!, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setDialogState(() {
                              selectedFile = null;
                              selectedFileName = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mp4', 'mp3', 'pdf', 'jpg', 'png'],
                      );
                      if (result != null && result.files.single.path != null) {
                        setDialogState(() {
                          selectedFile = File(result.files.single.path!);
                          selectedFileName = result.files.single.name;
                        });
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Subir Archivo'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                
                const SizedBox(height: 16),
                const Center(child: Text('O pega un enlace externo:', style: TextStyle(fontSize: 12, color: Colors.grey))),
                TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL (YouTube, Drive, etc.)', hintText: 'https://...')),
                
                if (isUploading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: uploadProgress, color: AppTheme.primary),
                  const SizedBox(height: 4),
                  Center(child: Text('Subiendo: ${(uploadProgress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10))),
                ],
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Visible para el turista'),
                    Switch(value: isActive, onChanged: (val) => setDialogState(() => isActive = val)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(ctx), 
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: isUploading ? null : () async {
                if (titleCtrl.text.isEmpty || (urlCtrl.text.isEmpty && selectedFile == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Título y URL o Archivo son obligatorios')));
                  return;
                }
                
                setDialogState(() => isUploading = true);
                
                String finalUrl = urlCtrl.text.trim();
                
                if (selectedFile != null) {
                  try {
                    final storageRef = FirebaseStorage.instance.ref().child('tourist_resources/${widget.tourName}/${DateTime.now().millisecondsSinceEpoch}_$selectedFileName');
                    final uploadTask = storageRef.putFile(selectedFile!);
                    
                    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
                      setDialogState(() {
                        uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
                      });
                    });
                    
                    await uploadTask;
                    finalUrl = await storageRef.getDownloadURL();
                  } catch (e) {
                    setDialogState(() => isUploading = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir: $e')));
                    return;
                  }
                }
                
                final Map<String, dynamic> data = {
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'url': finalUrl,
                  'tourName': widget.tourName,
                  'type': type,
                  'isActive': isActive,
                };
                
                if (doc == null) {
                  await _db.collection('tourist_resources').add({...data, 'createdAt': FieldValue.serverTimestamp()});
                } else {
                  await _db.collection('tourist_resources').doc(doc.id).update(data);
                }
                if (mounted) Navigator.pop(ctx);
              },
              child: Text(isUploading ? 'Subiendo...' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteResource(String id) async {
    await _db.collection('tourist_resources').doc(id).delete();
  }

  IconData _getIconForType(String type) {
    switch(type) {
      case 'Video': return Icons.play_circle_fill;
      case 'Cómic / Historia': return Icons.menu_book;
      case 'Audio': return Icons.audiotrack;
      default: return Icons.link;
    }
  }

  Color _getColorForType(String type) {
    switch(type) {
      case 'Video': return Colors.red;
      case 'Cómic / Historia': return Colors.orange;
      case 'Audio': return Colors.blue;
      default: return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recursos - ${widget.tourName}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: AppTheme.onPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('tourist_resources').where('tourName', isEqualTo: widget.tourName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No hay recursos en este tour.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () => _showAddEditDialog(doc),
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getColorForType(doc['type']).withOpacity(0.2),
                    child: Icon(_getIconForType(doc['type']), color: _getColorForType(doc['type'])),
                  ),
                  title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(doc['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(doc['url'], style: const TextStyle(fontSize: 10, color: Colors.blue), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (!(doc['isActive'] ?? true))
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Oculto (Inactivo)', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') _showAddEditDialog(doc);
                      if (val == 'delete') _deleteResource(doc.id);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
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
}