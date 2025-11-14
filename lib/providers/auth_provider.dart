import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_portel_application/models/user_model.dart';
import 'package:job_portel_application/services/firebase+_service.dart';
// import '../models/user_model.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:job_portel_application/services/firebase+_service.dart';

// class AuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseService _fs = FirebaseService();

//   User? currentUser;
//   UserModel? userModel;
//   bool loading = false;

//   AuthProvider() {
//     _auth.authStateChanges().listen(_onAuthStateChanged);
//   }

//   Future<void> _onAuthStateChanged(User? user) async {
//     currentUser = user;
//     if (user != null) {
//       final isAdmin = await _fs.checkIsAdmin(user.uid);
//       userModel = UserModel(
//         uid: user.uid,
//         email: user.email ?? '',
//         isAdmin: isAdmin,
//       );
//     } else {
//       userModel = null;
//     }
//     notifyListeners();
//   }

//   Future<String?> signIn(String email, String password) async {
//     loading = true;
//     notifyListeners();
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       // ensure user doc exists
//       await _fs.createUserRecord(cred.user!.uid, email, isAdmin: false);
//       loading = false;
//       notifyListeners();
//       return null;
//     } on FirebaseAuthException catch (e) {
//       loading = false;
//       notifyListeners();
//       return e.message;
//     }
//   }

//   Future<String?> register(
//     String email,
//     String password, {
//     bool isAdmin = false,
//   }) async {
//     loading = true;
//     notifyListeners();
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       await _fs.createUserRecord(cred.user!.uid, email, isAdmin: isAdmin);
//       loading = false;
//       notifyListeners();
//       return null;
//     } on FirebaseAuthException catch (e) {
//       loading = false;
//       notifyListeners();
//       return e.message;
//     }
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _fs = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;
  bool loading = false;

  // AuthProvider() {
  //   _auth.authStateChanges().listen(_onAuthChange);
  // }

  // void _onAuthChange(User? user) async {
  //   if (user == null) {
  //     userModel = null;
  //     notifyListeners();
  //     return;
  //   }

  //   final isAdmin = await _fs.checkIsAdmin(user.uid);

  //   userModel = UserModel(
  //     uid: user.uid,
  //     email: user.email ?? "",
  //     isAdmin: isAdmin,
  //   );

  //  notifyListeners();
  //}
  Future<String?> signIn(String email, String password) async {
    try {
      loading = true;
      notifyListeners();

      // Firebase Auth Sign In
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch User Document from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      if (!doc.exists) return "User record not found";

      userModel = UserModel.fromMap(doc.data()!, cred.user!.uid);

      loading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      loading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      loading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Future<String?> signIn(String email, String pass) async {
  //   loading = true;
  //   notifyListeners();
  //   try {
  //     final cred = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: pass,
  //     );

  //     await _fs.createUserRecord(cred.user!.uid, email);

  //     loading = false;
  //     notifyListeners();
  //     return null;
  //   } on FirebaseAuthException catch (e) {
  //     loading = false;
  //     notifyListeners();
  //     return e.message;
  //   }
  // }

  Future<String?> register(
    String email,
    String pass, {
    bool isAdmin = false,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      await _fs.createUserRecord(cred.user!.uid, email, isAdmin: isAdmin);

      loading = false;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      loading = false;
      notifyListeners();
      return e.message;
    }
  }

  //Future<void> signOut() async => await _auth.signOut();
  Future<void> signOut() async {
    await _auth.signOut();
    userModel = null;
    notifyListeners();
  }
}
