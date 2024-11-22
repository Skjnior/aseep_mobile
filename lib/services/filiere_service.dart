import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/filiere.dart';

class FiliereService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une filière
  Future<void> addFiliere(Filiere filiere) async {
    try {
      await _firestore.collection('Filieres').doc(filiere.ID).set(filiere.toJson());
      notifyListeners();
    } catch (e) {
      print("Erreur lors de l'ajout de la filière : $e");
    }
  }

  // Mettre à jour une filière
  Future<void> updateFiliere(String id, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('Filieres').doc(id).update(updatedData);
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour de la filière : $e");
    }
  }

  // Supprimer une filière
  Future<void> deleteFiliere(String id) async {
    try {
      await _firestore.collection('Filieres').doc(id).delete();
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la suppression de la filière : $e");
    }
  }

  // Récupérer une filière par ID
  Future<Map<String, dynamic>?> getFiliereById(String id) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Filieres').doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Erreur de récupération de la filière : $e");
      return null;
    }
  }


  // Stream pour récupérer toutes les filières
  Stream<List<Filiere>> getFilieresStream() {
    return _firestore.collection('Filieres').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Filiere.fromJson(doc.data())).toList();
    });
  }

  // Rechercher une filière par nom ou sigle
  Future<List<Filiere>> searchFilieres(String query) async {
    try {
      final snapshot = await _firestore
          .collection('Filieres')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) => Filiere.fromJson(doc.data())).toList();
    } catch (e) {
      print("Erreur lors de la recherche des filières : $e");
      return [];
    }
  }

  // Bloquer une filière
  Future<void> blockFiliere(String userId, String filiereId) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('BlockedFilieres')
          .doc(filiereId)
          .set({});
      notifyListeners();
    } catch (e) {
      print("Erreur lors du blocage de la filière : $e");
    }
  }

  // Débloquer une filière
  Future<void> unblockFiliere(String userId, String filiereId) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('BlockedFilieres')
          .doc(filiereId)
          .delete();
      notifyListeners();
    } catch (e) {
      print("Erreur lors du déblocage de la filière : $e");
    }
  }

  // Stream pour récupérer les filières bloquées
  Stream<List<Filiere>> getBlockedFilieresStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('BlockedFilieres')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedIds = snapshot.docs.map((doc) => doc.id).toList();

      final filieresDocs = await Future.wait(
        blockedIds.map((id) => _firestore.collection('Filieres').doc(id).get()),
      );

      return filieresDocs
          .where((doc) => doc.exists)
          .map((doc) => Filiere.fromJson(doc.data()!))
          .toList();
    });
  }

  // Signaler une filière
  Future<void> reportFiliere(String userId, String filiereId, String reason) async {
    try {
      final report = {
        'reportedBy': userId,
        'filiereId': filiereId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('FiliereReports').add(report);
    } catch (e) {
      print("Erreur lors du signalement de la filière : $e");
    }
  }
}
