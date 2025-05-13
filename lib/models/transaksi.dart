import 'user.dart';

class Transaksi {
  final int id;
  final int siswaId;
  final int? tagihanId;
  final String? jenisTagihan;
  final String? periode;
  final double jumlah;
  final DateTime tanggalBayar;
  final int petugasId;
  final String status;
  final String? hariBayar;
  final User petugas;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? jumlahTagihanDibayar;

  Transaksi({
    required this.id,
    required this.siswaId,
    this.tagihanId,
    this.jenisTagihan,
    this.periode,
    required this.jumlah,
    required this.tanggalBayar,
    required this.petugasId,
    required this.status,
    this.hariBayar,
    required this.petugas,
    required this.createdAt,
    required this.updatedAt,
    this.jumlahTagihanDibayar,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    print('Parsing Transaksi JSON: $json'); // Log untuk debugging
    return Transaksi(
      id: json['id'] as int,
      siswaId: json['siswa_id'] as int,
      tagihanId: json['tagihan_id'] as int?,
      jenisTagihan: json['jenis_tagihan'] as String?,
      periode: json['periode'] as String?,
      jumlah: json['jumlah'] is String
          ? double.parse(json['jumlah'])
          : (json['jumlah'] is int ? json['jumlah'].toDouble() : json['jumlah']),
      tanggalBayar: DateTime.parse(json['tanggal_bayar']), // Pastikan parsing benar
      petugasId: json['petugas_id'] as int,
      status: json['status'] as String,
      hariBayar: json['hari_bayar'] as String?,
      petugas: json['petugas'] != null ? User.fromJson(json['petugas']) : User(
        id: 0,
        name: 'Unknown',
        email: 'unknown@example.com',
        peran: 'unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      jumlahTagihanDibayar: json['jumlah_tagihan_dibayar'] as int?,
    );
  }
}