import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';

class NegocioScanScreen extends StatefulWidget {
  const NegocioScanScreen({super.key});

  @override
  State<NegocioScanScreen> createState() => _NegocioScanScreenState();
}

class _NegocioScanScreenState extends State<NegocioScanScreen> {
  late MobileScannerController controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      _isProcessing = true;
      final String code = barcodes.first.rawValue ?? '';
      _searchUserAndGivePoints(code);
    }
  }

  Future<void> _searchUserAndGivePoints(String code) async {
    try {
      final db = FirebaseFirestore.instance;
      // Buscar usuario por documentId, email o id
      final snapshot = await db.collection('users').where(
        Filter.or(
          Filter('documentId', isEqualTo: code),
          Filter('email', isEqualTo: code),
          Filter('id', isEqualTo: code),
        ),
      ).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        final userId = snapshot.docs.first.id;
        final userName = userData['name'] ?? 'Turista';
        if (mounted) _showAddPointsDialog(userId, userName);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no encontrado')),
          );
          setState(() { _isProcessing = false; });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar: $e')),
        );
        setState(() { _isProcessing = false; });
      }
    }
  }

  void _showManualEntryDialog() {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          scrollable: true,
          title: const Text(
            'Ingresar Código',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresa el correo, cédula o código del turista.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Código del turista',
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context);
                  _isProcessing = true;
                  _searchUserAndGivePoints(code);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
              ),
              child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddPointsDialog(String touristId, String touristName) {
    final TextEditingController pointsController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              scrollable: true,
              title: const Text(
                'Asignar Puntos',
                style: TextStyle(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Otorgando a: $touristName',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa la cantidad de puntos de bonificación que deseas otorgar.',
                      style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pointsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Puntos',
                        filled: true,
                        fillColor: AppTheme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.stars, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.security, color: AppTheme.secondary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Por seguridad, este registro de puntos quedará guardado en el historial de auditoría.',
                              style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () {
                    setState(() { _isProcessing = false; });
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    final pointsText = pointsController.text.trim();
                    final points = int.tryParse(pointsText);
                    if (points != null && points > 0) {
                      setDialogState(() => isSaving = true);
                      
                      try {
                        final db = FirebaseFirestore.instance;
                        
                        // 1. Log transaction
                        await db.collection('point_logs').add({
                          'touristId': touristId,
                          'touristName': touristName,
                          'points': points,
                          'type': 'earned_from_partner',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // 2. Add points to user
                        await db.collection('users').doc(touristId).update({
                          'points': FieldValue.increment(points),
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Se otorgaron $points puntos a $touristName exitosamente.')),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted) context.pop();
                          });
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                  ),
                  child: isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.onPrimary, strokeWidth: 2))
                    : const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Otorgar Puntos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Escanea el código QR\ndel usuario para sumar puntos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primary, width: 3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.flashlight_on,
                      onPressed: () => controller.toggleTorch(),
                    ),
                    _buildControlButton(
                      icon: Icons.keyboard,
                      onPressed: _showManualEntryDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
