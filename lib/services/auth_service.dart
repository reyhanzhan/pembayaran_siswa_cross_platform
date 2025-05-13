import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final storage = FlutterSecureStorage();
  String? _token;
  String? _peran;
  String? _name;

  // Login dan simpan token, peran, dan nama
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _peran = data['user']['peran'];
        _name = data['user']['name']; // Simpan nama pengguna

        // Simpan ke secure storage
        await storage.write(key: 'token', value: _token);
        await storage.write(key: 'peran', value: _peran);
        await storage.write(key: 'name', value: _name);

        return User.fromJson(data['user']);
      } else {
        throw Exception('Login gagal: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  // Dapatkan token dari storage
  Future<String?> getToken() async {
    if (_token == null) {
      _token = await storage.read(key: 'token');
    }
    return _token;
  }

  // Dapatkan peran dari storage
  Future<String?> getPeran() async {
    if (_peran == null) {
      _peran = await storage.read(key: 'peran');
    }
    return _peran;
  }

  // Dapatkan nama pengguna dari storage
  Future<String?> getUserName() async {
    if (_name == null) {
      _name = await storage.read(key: 'name');
    }
    return _name;
  }

  // Logout dan hapus semua data
  Future<void> logout() async {
    _token = null;
    _peran = null;
    _name = null;
    await storage.delete(key: 'token');
    await storage.delete(key: 'peran');
    await storage.delete(key: 'name');
  }

  // Perbarui data pengguna dari API (opsional, untuk sinkronisasi)
  Future<void> refreshUserData() async {
    final token = await getToken();
    if (token == null) throw Exception('Tidak ada token autentikasi');

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _peran = data['peran'];
      _name = data['name'];
      await storage.write(key: 'peran', value: _peran);
      await storage.write(key: 'name', value: _name);
    } else {
      throw Exception('Gagal menyinkronkan data pengguna: ${response.body}');
    }
  }

  // Cek apakah pengguna sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}