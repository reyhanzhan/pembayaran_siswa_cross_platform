class Transaksi {
  final int id;
  final int siswaId;
  final double jumlah;
  final String tanggalBayar;
  final int petugasId;
  final String status;

  Transaksi({
    required this.id,
    required this.siswaId,
    required this.jumlah,
    required this.tanggalBayar,
    required this.petugasId,
    required this.status,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      siswaId: json['siswa_id'],
      jumlah: double.parse(json['jumlah'].toString()),
      tanggalBayar: json['tanggal_bayar'],
      petugasId: json['petugas_id'],
      status: json['status'],
    );
  }
}