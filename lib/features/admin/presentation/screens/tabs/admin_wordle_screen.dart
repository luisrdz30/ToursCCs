import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';

class AdminWordleScreen extends StatefulWidget {
  const AdminWordleScreen({super.key});

  @override
  State<AdminWordleScreen> createState() => _AdminWordleScreenState();
}

class _AdminWordleScreenState extends State<AdminWordleScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _showAddEditDialog([DocumentSnapshot? doc]) {
    final wordCtrl = TextEditingController(text: doc?['word'] ?? '');
    final hintCtrl = TextEditingController(text: doc?['hint'] ?? '');
    final meaningCtrl = TextEditingController(text: doc?['meaning'] ?? '');
    final pointsCtrl = TextEditingController(text: (doc?['points'] ?? 10).toString());
    bool isActive = doc?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          title: Text(doc == null ? 'Nueva Palabra' : 'Editar Palabra', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: wordCtrl,
                  decoration: const InputDecoration(labelText: 'Palabra', hintText: 'Ej. CACAO o PICHINCHA'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hintCtrl,
                  decoration: const InputDecoration(labelText: 'Pista (Ayuda durante el juego)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: meaningCtrl,
                  decoration: const InputDecoration(labelText: 'Significado (Al terminar)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pointsCtrl,
                  decoration: const InputDecoration(labelText: 'Puntos de recompensa'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Activa para jugar'),
                    Switch(
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final word = wordCtrl.text.toUpperCase().trim();
                if (word.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La palabra no puede estar vacía')));
                  return;
                }
                
                final data = {
                  'word': word,
                  'hint': hintCtrl.text.trim(),
                  'meaning': meaningCtrl.text.trim(),
                  'points': int.tryParse(pointsCtrl.text) ?? 10,
                  'isActive': isActive,
                };
                
                try {
                  if (doc == null) {
                    await _db.collection('wordle_words').add({
                      ...data,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  } else {
                    await _db.collection('wordle_words').doc(doc.id).update(data);
                  }
                  if (mounted) {
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteWord(String id) async {
    await _db.collection('wordle_words').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Wordle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: AppTheme.onPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('wordle_words').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No hay palabras agregadas aún.'));
          
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return ListTile(
                onTap: () => _showAddEditDialog(doc),
                title: Text(doc['word'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                subtitle: Text('${doc['points']} pts • ${doc['meaning']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(doc['isActive'] ? Icons.check_circle : Icons.cancel, color: doc['isActive'] ? Colors.green : Colors.grey),
                    IconButton(icon: const Icon(Icons.edit, color: AppTheme.primary), onPressed: () => _showAddEditDialog(doc)),
                    IconButton(icon: const Icon(Icons.delete, color: AppTheme.error), onPressed: () => _deleteWord(doc.id)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}