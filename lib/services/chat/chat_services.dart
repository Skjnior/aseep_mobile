import 'package:aseep/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyServices extends ChangeNotifier {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
// Liste des utilisateurs chargés
  List<Map<String, dynamic>> _users = [];

  List<Map<String, dynamic>> get users => _users;


  // Rafraîchir les données des utilisateurs
  Future<void> refreshData() async {
    try {
      // Charger les utilisateurs depuis Firestore
      final usersStream = getUsersStreamExcludingBlockedAndDeleted();
      final usersList = await usersStream.first; // Obtenez la première émission
      _users = usersList;
      notifyListeners(); // Notifie les widgets abonnés des modifications
    } catch (e) {
      print("Erreur lors du rafraîchissement des données : $e");
    }
  }

// Méthode pour vérifier si un utilisateur existe en fonction de son email
  Future<bool> checkIfUserExists(String email) async {
    final snapshot = await _firestore
        .collection("Users")
        .where("email", isEqualTo: email)
        .get();

    return snapshot.docs.isNotEmpty;  // Si l'email existe dans la collection "Users"
  }

  // get all user stream except blocked
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlockedAndDeleted() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Utilisateur non connecté");
    }

    return _firestore.collection('Users')
        .doc(currentUser.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((blockedSnapshot) async {
      // Récupérer les identifiants des utilisateurs bloqués
      final blockedUserIds = blockedSnapshot.docs.map((doc) => doc.id).toSet();

      // Récupérer les utilisateurs supprimés par d'autres
      final deletedSnapshot = await _firestore
          .collection('Users')
          .doc(currentUser.uid)
          .collection('UsersDeletedByOtherUsers')
          .get();
      final deletedUserIds = deletedSnapshot.docs.map((doc) => doc.id).toSet();

      // Récupérer tous les utilisateurs
      final usersSnapshot = await _firestore.collection('Users').get();

      // Filtrer les utilisateurs
      return usersSnapshot.docs
          .where((doc) {
        final userId = doc.id;
        final data = doc.data();

        // Exclure les utilisateurs bloqués, supprimés et l'utilisateur courant
        return data['email'] != currentUser.email &&
            !blockedUserIds.contains(userId) &&
            !deletedUserIds.contains(userId);
      })
          .map((doc) => doc.data())
          .toList();
    });
  }


  /// recuperer les users qui n'ont echanger avec le currentUser
  Stream<List<Map<String, dynamic>>> getUsersNotInChatRooms() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Utilisateur non connecté");
    }

    // Récupérer les UIDs des utilisateurs impliqués dans les chat_rooms
    return _firestore.collection('chat_rooms').snapshots().asyncMap((chatRoomsSnapshot) async {
      final Set<String> involvedUserIds = {}; // Set pour stocker les UIDs uniques

      for (var chatRoomDoc in chatRoomsSnapshot.docs) {
        final chatRoomId = chatRoomDoc.id;

        // Récupérer les messages de chaque chat_room
        final messagesSnapshot = await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('message')
            .get();

        for (var messageDoc in messagesSnapshot.docs) {
          final messageData = messageDoc.data();
          involvedUserIds.add(messageData['senderID']);
          involvedUserIds.add(messageData['receiverID']);
        }
      }

      // Ajouter l'UID de l'utilisateur actuel pour l'exclure aussi
      involvedUserIds.add(currentUser.uid);

      // Parcourir la collection Users
      final usersSnapshot = await _firestore.collection('Users').get();

      return usersSnapshot.docs
          .where((userDoc) => !involvedUserIds.contains(userDoc.id)) // Exclure les utilisateurs impliqués
          .map((userDoc) => userDoc.data())
          .toList();
    });
  }









  // send message
  Future<void> sendMessage(String receiverId, String message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverId];
    ids.sort(); // sort this ids (this ensure the chatroomID is the same for any @ people)
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }





  Stream<QuerySnapshot> getAllMessages(String userID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }


  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Méthode pour obtenir les utilisateurs ayant un message en commun avec le current user
/*  Stream<List<String>> getUsersWithMessages(String currentUserId) {
    return _firestore.collection('messages') // La collection contenant vos messages
        .where('senderID', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((sentSnapshot) async {
      final Set<String> userIds = {};

      // Ajout des destinataires des messages envoyés par l'utilisateur courant
      for (var doc in sentSnapshot.docs) {
        userIds.add(doc['receiverID']);
      }

      // Ajout des messages reçus par l'utilisateur courant
      final receivedSnapshot = await _firestore
          .collection('messages')
          .where('receiverID', isEqualTo: currentUserId)
          .get();

      for (var doc in receivedSnapshot.docs) {
        userIds.add(doc['senderID']);
      }

      // Retirer l'utilisateur courant de la liste
      userIds.remove(currentUserId);

      return userIds.toList();
    });
  }*/

  // report user
  Future<void> reportMessage(String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('Reports').add(report);
  }

  // report user
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('Reports').add(report);
  }



  /* User Blocked */

  // block user
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserId)
        .delete();
    notifyListeners();
  }


  // get blocked users stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // get list of blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(
        blockedUserIds.map((id) => _firestore.collection('Users').doc(id).get()),
      );

      // return as a list
      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  } //





  /* Users deleted */
 /* Future<void> deleteUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('UsersDeletedByOtherUsers')
        .doc(userId)
        .set({});
    notifyListeners();
  }*/
  Future<void> deleteUser(String userId) async {
    final currentUser = _auth.currentUser;
    try {
      await _firestore
          .collection('Users')
          .doc(currentUser!.uid)
          .collection('UsersDeletedByOtherUsers')
          .doc(userId)
          .set({});
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la suppression de l'utilisateur : $e");
    }
  }


  // unblock user
  Future<void> unDeleteUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('UsersDeletedByOtherUsers')
        .doc(blockedUserId)
        .delete();
    notifyListeners();
  }


  // get Deleted users stream
  Stream<List<Map<String, dynamic>>> getDeletedUsersStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('UsersDeletedByOtherUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // get list of blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(
        blockedUserIds.map((id) => _firestore.collection('Users').doc(id).get()),
      );

      // return as a list
      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }



}
