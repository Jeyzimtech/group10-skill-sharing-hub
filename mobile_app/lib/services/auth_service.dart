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
        'name': name,
        'email': email,
        'dob': dob,
        'studentNumber': studentNumber,
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
}
