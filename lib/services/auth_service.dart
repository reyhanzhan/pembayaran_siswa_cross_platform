import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final storage = FlutterSecureStorage();

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'peran', value: data['user']['peran']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<String?> getPeran() async {
    return await storage.read(key: 'peran');
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'peran');
  }
}