import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AuthErrorType { invalidCredentials, emailAlreadyExists, networkError, serverError, unknown }

class AuthException implements Exception {
  final AuthErrorType type;
  final String message;
  const AuthException(this.type, this.message);
}

class AuthService {
  static const _baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator → host machine localhost
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  static Future<void> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        await _storage.write(key: _tokenKey, value: body['token'] as String);
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        throw const AuthException(AuthErrorType.invalidCredentials, 'Invalid email or password.');
      } else {
        throw AuthException(AuthErrorType.serverError, body['message'] ?? 'Server error. Please try again.');
      }
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const AuthException(AuthErrorType.networkError, 'No internet connection. Please check your network.');
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
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'dob': dob,
          'student_number': studentNumber,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body);
      if (res.statusCode == 201) {
        await _storage.write(key: _tokenKey, value: body['token'] as String);
      } else if (res.statusCode == 409) {
        throw const AuthException(AuthErrorType.emailAlreadyExists, 'An account with this email already exists.');
      } else {
        throw AuthException(AuthErrorType.serverError, body['message'] ?? 'Registration failed. Please try again.');
      }
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const AuthException(AuthErrorType.networkError, 'No internet connection. Please check your network.');
    } catch (_) {
      throw const AuthException(AuthErrorType.networkError, 'Unable to connect. Please try again.');
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        final body = jsonDecode(res.body);
        throw AuthException(AuthErrorType.serverError, body['message'] ?? 'Request failed. Please try again.');
      }
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const AuthException(AuthErrorType.networkError, 'No internet connection. Please check your network.');
    } catch (_) {
      throw const AuthException(AuthErrorType.networkError, 'Unable to connect. Please try again.');
    }
  }
}
