import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/siswa.dart';
import '../models/transaksi.dart';
import '../services/api_service.dart';

class SiswaDetailScreen extends StatefulWidget {
  final int siswaId;

  SiswaDetailScreen({required this.siswaId});

  @override
  _SiswaDetailScreenState createState() => _SiswaDetailScreenState();
}

class _SiswaDetailScreenState extends State<SiswaDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Siswa> siswaDetail;

  @override
  void initState() {
    super.initState();
    siswaDetail = apiService.getSiswaDetail(widget.siswaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Siswa',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: FutureBuilder<Siswa>(
        future: siswaDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Data siswa tidak ditemukan'));
          }

          final siswa = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama: ${siswa.user.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Email: ${siswa.user.email}'),
                Text('Total Tagihan: Rp ${siswa.totalTagihan.toStringAsFixed(0)}'),
                SizedBox(height: 20),
                Text(
                  'Riwayat Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: siswa.transaksi.isEmpty
                      ? Center(child: Text('Belum ada pembayaran'))
                      : ListView.builder(
                          itemCount: siswa.transaksi.length,
                          itemBuilder: (context, index) {
                            final transaksi = siswa.transaksi[index];
                            final dateTime = transaksi.tanggalBayar.toLocal(); // Langsung gunakan DateTime
                            final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
                            final day = DateFormat('EEEE', 'id_ID').format(dateTime);
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  'Rp ${transaksi.jumlah.toStringAsFixed(0)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '$formattedDate\nHari: $day\nPetugas: ${transaksi.petugas.name}\nStatus: ${transaksi.status}',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}