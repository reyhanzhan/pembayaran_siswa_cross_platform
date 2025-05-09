import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/siswa.dart';
import '../models/transaksi.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final AuthService authService = AuthService();

  Future<List<Siswa>> getSiswaList() async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/siswa'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Siswa.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data siswa: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> submitPayment(int siswaId, double jumlah) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$baseUrl/transaksi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'siswa_id': siswaId,
        'jumlah': jumlah,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mencatat pembayaran: ${response.body}');
    }
  }

  Future<Siswa> getSiswaDetail(int id) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/siswa/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Siswa.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil detail siswa: ${response.body}');
    }
  }
}
