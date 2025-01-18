import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  late FirebaseFirestore _firestore;

  Future<void> initialize() async {
    if (_initialized) return;

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDIRaTPS_FjjPk_Sw21iW_gy0KNE490D-8",
        authDomain: "village-attack.firebaseapp.com",
        projectId: "village-attack",
        storageBucket: "village-attack.appspot.com",
        messagingSenderId: "451264260248",
        appId: "1:451264260248:web:42890d2cf244341bc8c8ed",
        measurementId: "G-3TSSN1G1VC",
      ),
    );

    _firestore = FirebaseFirestore.instance;
    _initialized = true;
  }

  Future<List<Map<String, dynamic>>> fetchNodeMapData() async {
    if (!_initialized) {
      throw Exception('FirebaseService not initialized');
    }

    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('node_map').get();

      print('node_map');

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching node map data: $e');
      rethrow;
    }
  }
}
