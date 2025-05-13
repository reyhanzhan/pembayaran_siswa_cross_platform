class Tagihan {
  final int? id;
  final int? siswaId;
  final String? jenisTagihan;
  final double jumlah;
  final String? periode;
  final bool lunas;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tagihan({
    this.id,
    this.siswaId,
    this.jenisTagihan,
    required this.jumlah,
    this.periode,
    required this.lunas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tagihan.fromJson(Map<String, dynamic> json) {
    return Tagihan(
      id: json['id'] as int?,
      siswaId: json['siswa_id'] as int?,
      jenisTagihan: json['jenis_tagihan'] as String?,
      jumlah: json['jumlah'] is String
          ? double.parse(json['jumlah'].replaceAll(',', '.'))
          : (json['jumlah'] is int ? json['jumlah'].toDouble() : json['jumlah'].toDouble()),
      periode: json['periode'] as String?,
      lunas: json['lunas'] is bool
          ? json['lunas']
          : (json['lunas'] == 1 || json['lunas'] == "1"),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siswa_id': siswaId,
      'jenis_tagihan': jenisTagihan,
      'jumlah': jumlah,
      'periode': periode,
      'lunas': lunas ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}