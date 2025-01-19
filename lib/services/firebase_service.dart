import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  late FirebaseFirestore _firestore;
  late FirebaseAnalytics _analytics;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _firestore = FirebaseFirestore.instance;
      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNodeMapData() async {
    if (!_initialized) {
      throw Exception('FirebaseService not initialized');
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('node_map')
          .orderBy('nodeID') // Changed from 'nodeId'
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'nodeId': (doc.get('nodeID') ?? '').toString(), // Convert nodeID to string
              })
          .toList();
    } catch (e) {
      print('Error fetching node map data: $e');
      rethrow;
    }
  }

  Future<void> logGameEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Error logging analytics event: $e');
    }
  }
}