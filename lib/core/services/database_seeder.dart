import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createTestAccounts() async {
    print('--- INICIANDO CREACIÓN DE CUENTAS DE PRUEBA ---');
    final users = [
      {'email': 'admin_nuevo@test.com', 'role': 'admin', 'name': 'Administrador'},
      {'email': 'partner_nuevo@test.com', 'role': 'partner', 'name': 'Socio Comercial'},
      {'email': 'chofer_nuevo@test.com', 'role': 'driver', 'name': 'Chofer Test'},
      {'email': 'turista_nuevo@test.com', 'role': 'tourist', 'name': 'Turista Test'},
    ];

    for (var u in users) {
      String uid;
      try {
        final cred = await _auth.createUserWithEmailAndPassword(email: u['email']!, password: '123456');
        uid = cred.user!.uid;
        print('Creado usuario: ${u['email']}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('El usuario ${u['email']} ya existe, iniciando sesión para obtener UID...');
          final cred = await _auth.signInWithEmailAndPassword(email: u['email']!, password: '123456');
          uid = cred.user!.uid;
        } else {
          print('Error auth con ${u['email']}: $e');
          continue;
        }
      }

      await _db.collection('users').doc(uid).set({
        'email': u['email'],
        'role': u['role'],
        'name': u['name'],
        'createdAt': FieldValue.serverTimestamp(),
        // Add extra fields for tourist
        if (u['role'] == 'tourist') ...{
          'totalPoints': 1250,
          'level': 5,
          'currentMascot': 'León Marino',
          'documentId': '1234567890',
        }
      });
      print('Datos en Firestore actualizados para: ${u['email']} (Rol: ${u['role']})');
    }
    
    print('--- CREACIÓN DE CUENTAS COMPLETADA ---');
  }

  Future<void> seedAll() async {
    print('--- INICIANDO SEED DE BASE DE DATOS ---');
    // We insert a mock tourist directly into Firestore so the QR scanner can find it
    // without messing with FirebaseAuth state
    await _db.collection('users').doc('mock_tourist_qr').set({
      'name': 'Turista de Prueba QR',
      'email': 'turista_qr@test.com',
      'role': 'tourist',
      'documentId': '1234567890',
      'points': 500,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _seedTours();
    await _seedBusinesses();
    await _seedPromotions();
    await _seedScheduledTours();
    await _seedPassengers();
    await _seedTuristaData();
    print('--- SEED COMPLETADO ---');
  }

  Future<void> _seedScheduledTours() async {
    String driverId = 'mock_driver_1';
    try {
      final qs = await _db.collection('users').where('email', isEqualTo: 'chofer_nuevo@test.com').limit(1).get();
      if (qs.docs.isNotEmpty) {
        driverId = qs.docs.first.id;
      }
    } catch (_) {}

    final trips = [
      {
        'driverId': driverId,
        'tourId': 'tour1_id_mock',
        'tourTitle': 'City Tour Histórico',
        'date': Timestamp.fromDate(DateTime.now()),
        'status': 'en_curso',
        'totalPassengers': 15,
        'boardedPassengers': 0,
      },
      {
        'driverId': driverId,
        'tourId': 'tour2_id_mock',
        'tourTitle': 'Ruta de los Volcanes',
        'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'status': 'programado',
        'totalPassengers': 20,
        'boardedPassengers': 0,
      }
    ];
    for (var t in trips) {
      // Para tener un ID fijo y predecible en desarrollo, usamos .doc()
      await _db.collection('scheduled_tours').doc('trip_mock_${trips.indexOf(t)}').set(t);
    }
    print('Viajes asignados insertados');
  }

  Future<void> _seedPassengers() async {
    String touristId = 'tourist_1';
    try {
      final qs = await _db.collection('users').where('email', isEqualTo: 'turista_nuevo@test.com').limit(1).get();
      if (qs.docs.isNotEmpty) {
        touristId = qs.docs.first.id;
      }
    } catch (_) {}

    final pax = [
      {
        'tripId': 'trip_mock_0',
        'touristId': touristId,
        'touristName': 'Juan Pérez',
        'paxCount': 2,
        'hasBoarded': false,
        'documentId': '0102030405',
        'nationality': 'Ecuador',
      },
      {
        'tripId': 'trip_mock_0',
        'touristId': 'some_other_id',
        'touristName': 'Maria Gomez',
        'paxCount': 1,
        'hasBoarded': true,
        'documentId': '1712345678',
        'nationality': 'Colombia',
      }
    ];
    for (var p in pax) {
      await _db.collection('scheduled_tours').doc(p['tripId'] as String).collection('passengers').doc(p['touristId'] as String).set(p);
    }
    print('Pasajeros insertados');
  }

  Future<void> _seedTours() async {
    final tours = [
      {
        'title': 'City Tour Histórico',
        'description': 'Recorrido por el centro histórico, iglesias y plazas principales.',
        'imageUrl': 'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop',
        'price': 15.0,
        'pointsToEarn': 150,
        'durationMinutes': 240,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Ruta de los Volcanes',
        'description': 'Aventura de un día completo explorando la avenida de los volcanes.',
        'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=600&auto=format&fit=crop',
        'price': 45.0,
        'pointsToEarn': 300,
        'durationMinutes': 600,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (var t in tours) {
      await _db.collection('tours').add(t);
    }
    print('Tours insertados');
  }

  Future<void> _seedBusinesses() async {
    // Simulamos un negocio ya creado (idealmente el UID de 'partner@test.com')
    await _db.collection('businesses').doc('vista_hermosa_id').set({
      'name': 'Restaurante Vista Hermosa',
      'email': 'partner@test.com',
      'address': 'Centro Histórico',
      'phone': '0991234567',
      'category': 'Restaurante',
      'rating': 4.5,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Negocios insertados');
  }

  Future<void> wipeAll() async {
    print('--- INICIANDO WIPE DE BASE DE DATOS ---');
    final collections = [
      'tours', 'businesses', 'promotions', 'scheduled_tours',
      'users', 'tourist_rewards', 'tourist_wallet_history', 'culture_multimedia', 'wordle_words'
    ];

    for (String coll in collections) {
      final snapshot = await _db.collection(coll).get();
      for (var doc in snapshot.docs) {
        // No borramos recursivamente subcolecciones automáticamente en el lado del cliente, 
        // pero para nuestro seeder, las subcolecciones como 'passengers' están atadas al documento.
        // Las borraremos manualmente para 'scheduled_tours'.
        if (coll == 'scheduled_tours') {
          final paxSnap = await doc.reference.collection('passengers').get();
          for (var pax in paxSnap.docs) {
            await pax.reference.delete();
          }
        }
        await doc.reference.delete();
      }
    }
    print('--- WIPE COMPLETADO ---');
  }

  Future<void> _seedPromotions() async {
    final promos = [
      {
        'businessId': 'vista_hermosa_id',
        'businessName': 'Restaurante Vista Hermosa',
        'title': 'Locro de Papa Especial',
        'description': '15% de descuento en platos típicos',
        'imageUrl': 'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop',
        'pointsCost': 250,
        'isActive': true,
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'businessId': 'vista_hermosa_id',
        'businessName': 'Restaurante Vista Hermosa',
        'title': 'Descuento Fin de Año',
        'description': '20% descuento para grupos',
        'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=600&auto=format&fit=crop',
        'pointsCost': 300,
        'isActive': true,
        'isApproved': false, // Pendiente de revisión por el Admin
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (var p in promos) {
      await _db.collection('promotions').add(p);
    }
    print('Promociones insertadas');
  }

  Future<void> _seedTuristaData() async {
    String touristId = 'tourist_1';
    try {
      final qs = await _db.collection('users').where('email', isEqualTo: 'turista_nuevo@test.com').limit(1).get();
      if (qs.docs.isNotEmpty) {
        touristId = qs.docs.first.id;
      }
    } catch (_) {}

    // Generar datos específicos para el perfil del turista
    await _db.collection('users').doc(touristId).set({
      'name': 'Juan Pérez',
      'email': 'turista_nuevo@test.com',
      'role': 'tourist',
      'totalPoints': 1200,
      'level': 3,
      'currentMascot': 'Leon Marino',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Simular Recompensas adquiridas
    await _db.collection('tourist_rewards').add({
      'touristId': touristId,
      'promotionId': 'promo_mock_id',
      'businessName': 'Restaurante Vista Hermosa',
      'title': 'Locro de Papa Especial',
      'status': 'active',
      'acquiredAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
    });

    // Simular Historial de Billetera
    final history = [
      {'touristId': touristId, 'type': 'earn', 'amount': 200, 'description': 'Tour Mitad del Mundo completado', 'date': FieldValue.serverTimestamp()},
      {'touristId': touristId, 'type': 'spend', 'amount': 150, 'description': 'Canje en Restaurante Vista Hermosa', 'date': FieldValue.serverTimestamp()},
      {'touristId': touristId, 'type': 'earn', 'amount': 50, 'description': 'Escaneo QR en parada', 'date': FieldValue.serverTimestamp()},
    ];

    for (var h in history) {
      await _db.collection('tourist_wallet_history').add(h);
    }

    // Simular Cultura y Multimedia
    await _db.collection('culture_multimedia').add({
      'type': 'glossary',
      'title': 'Chuchaqui',
      'description': 'Resaca o malestar después de beber.',
      'pointsToUnlock': 0,
      'isUnlocked': true,
    });

    await _db.collection('culture_multimedia').add({
      'type': 'souvenir3d',
      'title': 'Mitad del Mundo',
      'description': 'Modelo 3D del monumento.',
      'pointsToUnlock': 500,
      'isUnlocked': false,
    });

    // Simular palabras del Wordle
    final words = [
      {'word': 'CACAO', 'hint': 'El pepa de oro del Ecuador', 'meaning': 'Principal producto de exportación histórica.', 'points': 50, 'isActive': true},
      {'word': 'GUAYAS', 'hint': 'Río principal de la costa', 'meaning': 'Río y provincia más poblada.', 'points': 80, 'isActive': true},
      {'word': 'CHAGRA', 'hint': 'Personaje andino a caballo', 'meaning': 'Campesino de la sierra ecuatoriana.', 'points': 100, 'isActive': true},
    ];
    for (var w in words) {
      await _db.collection('wordle_words').add({
        ...w,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    print('Datos del turista insertados');
  }
}
