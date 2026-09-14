import 'package:flutter/material.dart';

class TuristaBridgeScreen extends StatelessWidget {
  const TuristaBridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Turista')),
      body: const Center(
        child: Text('Bienvenido Turista. Aquí irá tu itinerario y gamificación.'),
      ),
    );
  }
}

class ChoferBridgeScreen extends StatelessWidget {
  const ChoferBridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Chofer')),
      body: const Center(
        child: Text('Bienvenido Chofer. Aquí irá tu mapa y escáner QR.'),
      ),
    );
  }
}

class NegocioBridgeScreen extends StatelessWidget {
  const NegocioBridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Socios / Negocio')),
      body: const Center(
        child: Text('Bienvenido Socio. Aquí validarás descuentos.'),
      ),
    );
  }
}

class AdminBridgeScreen extends StatelessWidget {
  const AdminBridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administración')),
      body: const Center(
        child: Text('Bienvenido Admin. Aquí verás el CRM y métricas.'),
      ),
    );
  }
}
