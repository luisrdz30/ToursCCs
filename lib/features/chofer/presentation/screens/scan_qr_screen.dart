import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasPermission = false;
  bool _isProcessing = false;
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';
      if (code.isNotEmpty) {
        _processCode(code);
      }
    }
  }

  void _processCode(String code) {
    setState(() {
      _isProcessing = true;
    });
    
    // Simular un escaneo exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Acceso Concedido', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSecondaryContainer)),
                  Text('Código válido', style: TextStyle(color: AppTheme.onSecondaryContainer)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.secondaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navegar al detalle del turista
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go('/chofer/tourist/$code');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner Camera
          if (_hasPermission)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            )
          else
            const Center(
              child: Text(
                'Se requiere permiso de cámara para escanear',
                style: TextStyle(color: Colors.white),
              ),
            ),

          // Overlay (Simulated Viewfinder)
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            children: const [
                              Text(
                                'Escanea el código QR del pasajero',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                              Text(
                                'Apunta la cámara hacia el boleto',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Viewfinder frame
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryContainer, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Manual input fallback
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _manualInputController,
                                decoration: InputDecoration(
                                  hintText: 'N° de Cédula o Pasaporte / touristId',
                                  filled: true,
                                  fillColor: AppTheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_manualInputController.text.isNotEmpty) {
                                      _processCode(_manualInputController.text);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: const Text('Verificar', style: TextStyle(color: AppTheme.onPrimary)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: AppTheme.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                'Zizi\'s Tour',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.route, 'Viajes', false, () {
            context.go('/chofer');
          }),
          _buildNavItem(Icons.qr_code_scanner, 'Escanear', true, () {}),
          _buildNavItem(Icons.group, 'Pasajeros', false, () {
            context.go('/chofer/passengers/t1');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.secondaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}