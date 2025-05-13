import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return FutureBuilder<Map<String, String?>>(
      future: _getUserData(authService), // Ambil peran dan nama
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4FC3F7), Colors.white],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Memuat Dashboard...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final userData = snapshot.data!;
        final peran = userData['peran'] ?? 'Pengguna';
        final userName = userData['name'] ?? peran; // Gunakan nama jika ada, fallback ke peran

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
                ),
              ),
            ),
            title: Row(
              children: [
                // Placeholder Logo (Ganti dengan logo resmi jika ada)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.school,
                    size: 24,
                    color: Color(0xFF1976D2),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'SMK Kartini Surabaya',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FC3F7), Colors.white],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Selamat Datang, $userName!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Anda login sebagai $peran',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Tombol "Catat Pembayaran" untuk petugas
                          if (peran == 'petugas_koperasi' || peran == 'petugas_bendahara')
                            _buildActionCard(
                              context,
                              title: 'Catat Pembayaran',
                              icon: Icons.payment,
                              onTap: () => Navigator.pushNamed(context, '/payment'),
                            ),
                          // Tombol "Kelola Tagihan" untuk petugas
                          if (peran == 'petugas_koperasi' || peran == 'petugas_bendahara')
                            _buildActionCard(
                              context,
                              title: 'Kelola Tagihan',
                              icon: Icons.receipt_long,
                              onTap: () => Navigator.pushNamed(context, '/tagihan'),
                            ),
                          // Tombol "Lihat Daftar Siswa" untuk semua peran
                          _buildActionCard(
                            context,
                            title: 'Lihat Daftar Siswa',
                            icon: Icons.group,
                            onTap: () => Navigator.pushNamed(context, '/siswa_list'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk mengambil peran dan nama pengguna
  Future<Map<String, String?>> _getUserData(AuthService authService) async {
    final peran = await authService.getPeran();
    // Asumsi AuthService memiliki metode getUserName (tambahkan jika belum ada)
    final name = await authService.getUserName(); // Placeholder untuk nama pengguna
    return {'peran': peran, 'name': name};
  }

  // Widget untuk membuat kartu aksi dengan animasi
  Widget _buildActionCard(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          splashColor: Color(0xFF4FC3F7).withOpacity(0.3),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Color(0xFF1976D2),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}