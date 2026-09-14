import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Iniciar sesión
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Obtener rol del usuario desde Firestore
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? 'tourist';
      }
      return 'tourist'; // default
    } catch (e) {
      print('Error obteniendo rol: \$e');
      return 'tourist';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Crear usuario desde el Admin (envía correo de restablecimiento/creación de contraseña)
  Future<void> createUserFromAdmin({
    required String email,
    required String role,
    required String name,
    required String documentId,
    required String country,
  }) async {
    try {
      // 1. In Firebase Client SDK, createUserWithEmailAndPassword logs the new user in, kicking out the Admin.
      // To prevent this, we initialize a secondary Firebase App just for creating users.
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: _auth.app.options,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      final tempPassword = 'TempPassword123!';
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        // 2. Guardar su perfil y rol en Firestore usando la app principal
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'fullName': name, // Guardamos también fullName por consistencia con otros módulos
          'email': email,
          'role': role,
          'documentId': documentId,
          'country': country,
          'createdAt': FieldValue.serverTimestamp(),
          'pointsBalance': 0, // Iniciar balance de puntos
        });

        // 3. Enviar correo de restablecimiento de contraseña
        await secondaryAuth.sendPasswordResetEmail(email: email);
      }
      
      // We log out the secondary instance to clean up
      await secondaryAuth.signOut();
      
    } catch (e) {
      rethrow;
    }
  }
}
