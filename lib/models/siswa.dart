import 'user.dart';
import 'transaksi.dart';

class Siswa {
  final int id;
  final int userId;
  final String? nama;
  final String? kelas;
  final String? nis;
  final double totalTagihan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final List<Transaksi> transaksi;

  Siswa({
    required this.id,
    required this.userId,
    this.nama,
    this.kelas,
    this.nis,
    required this.totalTagihan,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.transaksi,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    print('Parsing Siswa JSON: $json'); // Tambahkan log untuk debugging
    return Siswa(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      nama: json['nama'] as String?, // Pastikan parsing nama benar
      kelas: json['kelas'] as String?,
      nis: json['nis'] as String?,
      totalTagihan: json['total_tagihan'] is String
          ? double.parse(json['total_tagihan'])
          : (json['total_tagihan'] is int ? json['total_tagihan'].toDouble() : json['total_tagihan']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : User(
        id: 0,
        name: json['nama'] as String? ?? 'Unknown', // Gunakan nama sebagai fallback
        email: 'unknown@example.com',
        peran: 'unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      transaksi: json['transaksi'] != null
          ? (json['transaksi'] as List).map((i) => Transaksi.fromJson(i)).toList()
          : [],
    );
  }
}