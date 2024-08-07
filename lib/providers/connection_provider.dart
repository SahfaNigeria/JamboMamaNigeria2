import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionStateModel with ChangeNotifier {
  bool _hasRequestedConnection = false;

  bool get hasRequestedConnection => _hasRequestedConnection;

  Future<void> sendConnectionRequest(
      String requesterId, String professionalId) async {
    await FirebaseFirestore.instance.collection('connection_requests').add({
      'requester_id': requesterId,
      'professional_id': professionalId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    _hasRequestedConnection = true;
    notifyListeners();
  }

  void resetConnectionRequest() {
    _hasRequestedConnection = false;
    notifyListeners();
  }
}
