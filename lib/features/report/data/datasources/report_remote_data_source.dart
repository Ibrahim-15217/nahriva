import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nahriva/features/report/data/models/report_model.dart';

class ReportRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ReportRemoteDataSource({
    FirebaseFirestore? firestoreInstance,
    FirebaseStorage? storageInstance,
  })  : _firestore = firestoreInstance ?? FirebaseFirestore.instance,
        _storage = storageInstance ?? FirebaseStorage.instance;

  Future<String> uploadPhoto(String reportId, String photoPath) async {
    final ref = _storage.ref('reports/$reportId/photo.jpg');
    final bytes = await _readBytes(photoPath);
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<Uint8List> _readBytes(String path) async {
    if (kIsWeb) {
      final response = await http.get(Uri.parse(path));
      return response.bodyBytes;
    }
    return await File(path).readAsBytes();
  }

  Future<void> createReport(ReportModel report) async {
    await _firestore.collection('reports').doc(report.id).set(report.toFirestore());
  }

  Future<ReportModel?> getReport(String id) async {
    final doc = await _firestore.collection('reports').doc(id).get();
    if (!doc.exists) return null;
    return ReportModel.fromFirestore(doc);
  }

  Stream<List<ReportModel>> getReportsStream() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }

  Future<void> updateReport(String id, Map<String, dynamic> data) async {
    await _firestore.collection('reports').doc(id).update(data);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
