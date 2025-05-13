import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/siswa.dart';
import '../models/transaksi.dart';
import '../models/tagihan.dart';
import 'auth_service.dart';
import '../models/user.dart';

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

  Future<Map<String, dynamic>> submitPayment(
      int siswaId, int? tagihanId, double jumlah) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final body = jsonEncode({
      'siswa_id': siswaId,
      'tagihan_id': tagihanId,
      'jumlah': jumlah,
    });

    print('Mengirim data pembayaran: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/transaksi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print('Status Code (submitPayment): ${response.statusCode}');
    print('Response Body (submitPayment): ${response.body ?? 'null'}');

    if (response.statusCode == 201) {
      if (response.body == null) {
        throw Exception('Respons dari server kosong');
      }
      final data = jsonDecode(response.body);
      final transaksiData = data['transaksi'] as Map<String, dynamic>;

      Tagihan? tagihan;
      if (tagihanId != null) {
        tagihan = await getTagihanDetail(tagihanId);
      }

      return {
        'transaksi': Transaksi(
          id: transaksiData['id'] as int,
          siswaId: transaksiData['siswa_id'] as int,
          tagihanId: tagihanId,
          jumlah: transaksiData['jumlah'] is String
              ? double.parse(transaksiData['jumlah'])
              : (transaksiData['jumlah'] is int ? transaksiData['jumlah'].toDouble() : transaksiData['jumlah']),
          tanggalBayar: DateTime.parse(transaksiData['tanggal_bayar']),
          petugasId: transaksiData['petugas_id'] as int,
          status: transaksiData['status'] as String,
          createdAt: DateTime.parse(transaksiData['created_at']),
          updatedAt: DateTime.parse(transaksiData['updated_at']),
          jenisTagihan: tagihan?.jenisTagihan,
          periode: tagihan?.periode,
          hariBayar: null,
          petugas: User(
            id: 1,
            name: 'Test User',
            email: 'test@example.com',
            peran: 'petugas_koperasi',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          jumlahTagihanDibayar: 1, // Sekarang parameter ini valid
        ),
        'sisa_tagihan': data['sisa_tagihan'],
      };
    } else {
      throw Exception('Gagal mencatat pembayaran: ${response.body ?? 'No response body'} (Status: ${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> submitMultiplePayments(
      int siswaId,
      List<int> tagihanIds,
      double totalJumlah,
      List<Tagihan> selectedTagihanList,
  ) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final body = jsonEncode({
      'siswa_id': siswaId,
      'tagihan_ids': tagihanIds,
      'jumlah': totalJumlah,
    });

    print('Mengirim data pembayaran multiple: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/transaksi/multiple'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print('Status Code (submitMultiplePayments): ${response.statusCode}');
    print('Response Body (submitMultiplePayments): ${response.body ?? 'null'}');

    if (response.statusCode == 201) {
      if (response.body == null) {
        throw Exception('Respons dari server kosong');
      }
      final data = jsonDecode(response.body);
      final transaksiData = data['transaksi'] as Map<String, dynamic>;

      return {
        'transaksi': Transaksi(
          id: transaksiData['id'] as int,
          siswaId: transaksiData['siswa_id'] as int,
          tagihanId: null,
          jumlah: transaksiData['jumlah'] is String
              ? double.parse(transaksiData['jumlah'])
              : (transaksiData['jumlah'] is int ? transaksiData['jumlah'].toDouble() : transaksiData['jumlah']),
          tanggalBayar: DateTime.parse(transaksiData['tanggal_bayar']),
          petugasId: transaksiData['petugas_id'] as int,
          status: transaksiData['status'] as String,
          createdAt: DateTime.parse(transaksiData['created_at']),
          updatedAt: DateTime.parse(transaksiData['updated_at']),
          jenisTagihan: selectedTagihanList.map((t) => t.jenisTagihan).join(', '),
          periode: selectedTagihanList.map((t) => t.periode).join(', '),
          hariBayar: null,
          petugas: User(
            id: 1,
            name: 'Test User',
            email: 'test@example.com',
            peran: 'petugas_koperasi',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          jumlahTagihanDibayar: selectedTagihanList.length, // Sekarang parameter ini valid
        ),
        'sisa_tagihan': data['sisa_tagihan'],
      };
    } else {
      throw Exception('Gagal mencatat pembayaran: ${response.body ?? 'No response body'} (Status: ${response.statusCode})');
    }
  }

  Future<List<Tagihan>> getTagihan() async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/tagihan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Tagihan.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data tagihan: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createTagihan(
      int siswaId, String jenisTagihan, double jumlah, String periode) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$baseUrl/tagihan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'siswa_id': siswaId,
        'jenis_tagihan': jenisTagihan,
        'jumlah': jumlah,
        'periode': periode,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menambahkan tagihan: ${response.body}');
    }
  }

  Future<List<Tagihan>> getTagihanBelumLunas(int siswaId) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    print('Mengambil tagihan belum lunas untuk siswa ID: $siswaId');
    print('Token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/tagihan/belum-lunas/$siswaId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code (getTagihanBelumLunas): ${response.statusCode}');
    print('Response Body (getTagihanBelumLunas): ${response.body ?? 'null'}');

    if (response.statusCode == 200) {
      if (response.body == null) {
        print('Response body is null, returning empty list');
        return [];
      }
      final List<dynamic> data = jsonDecode(response.body);
      print('Data Tagihan Sebelum Parsing: $data');
      return data.map((json) => Tagihan.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil tagihan belum lunas: ${response.body ?? 'No response body'}');
    }
  }

  Future<Tagihan> getTagihanDetail(int tagihanId) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/tagihan/$tagihanId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code (getTagihanDetail): ${response.statusCode}');
    print('Response Body (getTagihanDetail): ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Tagihan.fromJson(jsonData);
    } else {
      throw Exception('Gagal mengambil detail tagihan: ${response.body}');
    }
  }

  Future<Siswa> getSiswaDetail(int id) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    print('Mengambil detail siswa untuk ID: $id');
    print('Token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/siswa/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code (getSiswaDetail): ${response.statusCode}');
    print('Response Body (getSiswaDetail): ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('Data Siswa: $jsonData');
      return Siswa.fromJson(jsonData);
    } else {
      throw Exception('Gagal mengambil detail siswa: ${response.body}');
    }
  }
}