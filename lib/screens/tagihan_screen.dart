import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // Untuk animasi sederhana
import '../models/tagihan.dart';
import '../services/api_service.dart';

class TagihanScreen extends StatefulWidget {
  @override
  _TagihanScreenState createState() => _TagihanScreenState();
}

class _TagihanScreenState extends State<TagihanScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Tagihan>> tagihanList;
  final _siswaIdController = TextEditingController();
  final _jenisTagihanController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _periodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tagihanList = apiService.getTagihan();
  }

  void _addTagihan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await apiService.createTagihan(
        int.parse(_siswaIdController.text),
        _jenisTagihanController.text,
        double.parse(_jumlahController.text),
        _periodeController.text,
      );
      setState(() {
        tagihanList = apiService.getTagihan(); // Refresh daftar tagihan
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tagihan berhasil ditambahkan'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _siswaIdController.clear();
      _jenisTagihanController.clear();
      _jumlahController.clear();
      _periodeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToTop() {
    // Fungsi untuk scroll ke atas
    Scrollable.ensureVisible(context, alignment: 0.0, duration: Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 24,
                color: Color(0xFF1976D2),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Kelola Tagihan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4FC3F7).withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Tagihan Baru',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Isi detail tagihan untuk menambahkan tagihan baru.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _siswaIdController,
                          decoration: InputDecoration(
                            labelText: 'ID Siswa',
                            labelStyle: TextStyle(color: Color(0xFF1976D2)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF4FC3F7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                            ),
                            prefixIcon: Icon(Icons.person, color: Color(0xFF1976D2)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ID Siswa tidak boleh kosong';
                            }
                            if (int.tryParse(value) == null) {
                              return 'ID Siswa harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _jenisTagihanController,
                          decoration: InputDecoration(
                            labelText: 'Jenis Tagihan (SPP/LKS)',
                            labelStyle: TextStyle(color: Color(0xFF1976D2)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF4FC3F7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                            ),
                            prefixIcon: Icon(Icons.description, color: Color(0xFF1976D2)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis Tagihan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _jumlahController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Tagihan (Rp)',
                            labelStyle: TextStyle(color: Color(0xFF1976D2)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF4FC3F7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                            ),
                            prefixIcon: Icon(Icons.money, color: Color(0xFF1976D2)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah Tagihan tidak boleh kosong';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Jumlah Tagihan harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _periodeController,
                          decoration: InputDecoration(
                            labelText: 'Periode (contoh: April 2025)',
                            labelStyle: TextStyle(color: Color(0xFF1976D2)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF4FC3F7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                            ),
                            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Periode tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                              )
                            : ElevatedButton.icon(
                                onPressed: _addTagihan,
                                icon: Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  'Tambah Tagihan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1976D2),
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Daftar Tagihan',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              SizedBox(height: 10),
              Scrollbar(
                thumbVisibility: true,
                thickness: 6,
                radius: Radius.circular(10),
                child: FutureBuilder<List<Tagihan>>(
                  future: tagihanList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada tagihan',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      );
                    }

                    final tagihan = snapshot.data!;
                    return ListView.separated(
                      shrinkWrap: true, // Biarkan ListView menyesuaikan tinggi dalam SingleChildScrollView
                      physics: NeverScrollableScrollPhysics(), // Biarkan SingleChildScrollView menangani scroll
                      padding: EdgeInsets.only(bottom: 20),
                      itemCount: tagihan.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = tagihan[index];
                        return FadeInDown(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Detail tagihan ${item.jenisTagihan} - ${item.periode}'),
                                    backgroundColor: Color(0xFF1976D2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              leading: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.lunas ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item.lunas ? Icons.check_circle : Icons.error,
                                  color: item.lunas ? Colors.green : Colors.red,
                                  size: 30,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.jenisTagihan ?? 'Tidak Diketahui'} - ${item.periode ?? 'Tidak Diketahui'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.lunas ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.lunas ? "Lunas" : "Belum Lunas",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Rp ${item.jumlah.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(color: Colors.grey[600]),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[400],
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // SizedBox(height: 20),
              // Center(
              //   child: ElevatedButton.icon(
              //     onPressed: _scrollToTop,
              //     icon: Icon(Icons.arrow_upward, color: Colors.white),
              //     label: Text(
              //       'Kembali ke Atas',
              //       style: GoogleFonts.poppins(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white,
              //       ),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Color(0xFF1976D2),
              //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       elevation: 5,
              //     ),
              //   ),
              // ),
            
            ],
          ),
        ),
      ),
    );
  }
}