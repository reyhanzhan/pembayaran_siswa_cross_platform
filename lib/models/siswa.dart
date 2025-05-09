import 'user.dart';
import 'transaksi.dart';

class Siswa {
  final int id;
  final int userId;
  final double totalTagihan;
  final User user;
  final List<Transaksi> transaksi;

  Siswa({
    required this.id,
    required this.userId,
    required this.totalTagihan,
    required this.user,
    required this.transaksi,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'],
      userId: json['user_id'],
      totalTagihan: double.parse(json['total_tagihan'].toString()),
      user: User.fromJson(json['user']),
      transaksi: json['transaksi'] != null
          ? (json['transaksi'] as List).map((i) => Transaksi.fromJson(i)).toList()
          : [],
    );
  }
}