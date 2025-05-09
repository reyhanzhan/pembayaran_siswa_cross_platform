import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return FutureBuilder<String?>(
      future: authService.getPeran(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final peran = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text('Dashboard'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Selamat datang, $peran!', style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                if (peran == 'petugas_koperasi' || peran == 'petugas_bendahara')
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/payment'),
                    child: Text('Catat Pembayaran'),
                  ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/siswa_list'),
                  child: Text('Lihat Daftar Siswa'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}