import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';

class SiswaListScreen extends StatefulWidget {
  @override
  _SiswaListScreenState createState() => _SiswaListScreenState();
}

class _SiswaListScreenState extends State<SiswaListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Siswa>> siswaList;

  @override
  void initState() {
    super.initState();
    siswaList = apiService.getSiswaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Siswa')),
      body: FutureBuilder<List<Siswa>>(
        future: siswaList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data siswa'));
          }

          final siswa = snapshot.data!;
          return ListView.builder(
            itemCount: siswa.length,
            itemBuilder: (context, index) {
              final item = siswa[index];
              return ListTile(
                title: Text(item.user.name),
                subtitle: Text('Tagihan: Rp ${item.totalTagihan.toStringAsFixed(0)}'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/siswa_detail',
                    arguments: item.id, // Kirim siswaId sebagai argumen
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}