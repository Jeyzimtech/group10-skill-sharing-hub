import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthErrorType { invalidCredentials, emailAlreadyExists, networkError, serverError, unknown }

class AuthException implements Exception {
  final AuthErrorType type;
  final String message;
  const AuthException(this.type, this.message);
}

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<String?> getToken() async {
    return _auth.currentUser?.uid;
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
        case 'wrong-password':
          throw const AuthException(AuthErrorType.invalidCredentials, 'Invalid email or password.');
        case 'user-disabled':
          throw const AuthException(AuthErrorType.serverError, 'This account has been disabled.');
        default:
          throw AuthException(AuthErrorType.serverError, e.message ?? 'Authentication failed. Please try again.');
      }
    } catch (_) {
      throw const AuthException(AuthErrorType.networkError, 'Unable to connect. Please try again.');
    }
  }

  static Future<void> register({
    required String name,
    required String email,
    required String dob,
    required String studentNumber,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(AuthErrorType.unknown, 'Registration failed. Please try again.');
      }

      await user.updateDisplayName(name);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'dob': dob,
        'studentNumber': studentNumber,
        'isTutor': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const AuthException(AuthErrorType.emailAlreadyExists, 'An account with this email already exists.');
        case 'invalid-email':
          throw const AuthException(AuthErrorType.invalidCredentials, 'Invalid email address.');
        case 'weak-password':
          throw const AuthException(AuthErrorType.invalidCredentials, 'Password is too weak.');
        default:
          throw AuthException(AuthErrorType.serverError, e.message ?? 'Registration failed. Please try again.');
      }
    } catch (_) {
      throw const AuthException(AuthErrorType.networkError, 'Unable to connect. Please try again.');
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
          throw const AuthException(AuthErrorType.invalidCredentials, 'No user found with this email.');
        default:
          throw AuthException(AuthErrorType.serverError, e.message ?? 'Request failed. Please try again.');
      }
    } catch (_) {
      throw const AuthException(AuthErrorType.networkError, 'Unable to connect. Please try again.');
    }
  }

  static Future<void> becomeTutor({
    required String bio,
    required String skills,
    required double rate,
    required double experience,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Fetch latest user data from Firestore to ensure name/photo are current
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final name = userData['name'] ?? user.displayName;
    final photoUrl = userData['photoUrl'] ?? user.photoURL;

    final tutorData = {
      'uid': user.uid,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'skills': skills,
      'rate': rate,
      'experience': experience,
      'rating': 5.0,
      'available': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).update({
      'isTutor': true,
      'tutorProfile': tutorData,
    });

    await _firestore.collection('tutors').doc(user.uid).set(tutorData);
  }

  static Future<void> leaveTutor() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'isTutor': false,
      'tutorProfile': FieldValue.delete(),
    });

    await _firestore.collection('tutors').doc(user.uid).delete();
  }

  static Future<void> postReview({
    required String tutorUid,
    required String comment,
    required double rating,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final name = userData['name'] ?? user.displayName ?? 'Anonymous';
    final photoUrl = userData['photoUrl'] ?? user.photoURL ?? '';

    await _firestore.collection('reviews').add({
      'tutorUid': tutorUid,
      'reviewerName': name,
      'reviewerPhotoUrl': photoUrl,
      'comment': comment,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Optionally update tutor's overall rating here if needed
  }

  static Stream<DocumentSnapshot> getUserData() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  static Future<void> updateProfile({String? name, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> updates = {};
    if (name != null) {
      await user.updateDisplayName(name);
      updates['name'] = name;
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
      updates['photoUrl'] = photoUrl;
      // If user is a tutor, update the tutorProfile too
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && (doc.data()?['isTutor'] ?? false)) {
        await _firestore.collection('users').doc(user.uid).update({
          'tutorProfile.photoUrl': photoUrl
        });
        await _firestore.collection('tutors').doc(user.uid).update({
          'photoUrl': photoUrl
        });
      }
    }

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updates);
    }
  }
}
