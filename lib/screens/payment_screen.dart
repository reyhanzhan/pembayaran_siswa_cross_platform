import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tagihan.dart';
import '../services/api_service.dart';
import 'receipt_screen.dart';
import '../models/siswa.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _siswaIdController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isLoading = false;
  List<Tagihan> tagihanBelumLunas = [];
  List<Tagihan> selectedTagihanList = [];
  final _formKey = GlobalKey<FormState>();

  void _loadTagihanBelumLunas() async {
    if (_siswaIdController.text.isEmpty) {
      setState(() {
        tagihanBelumLunas = [];
        selectedTagihanList = [];
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final siswaId = int.tryParse(_siswaIdController.text);
      if (siswaId != null) {
        final tagihan = await apiService.getTagihanBelumLunas(siswaId);
        setState(() {
          tagihanBelumLunas = tagihan;
          selectedTagihanList = [];
        });
      } else {
        setState(() {
          tagihanBelumLunas = [];
          selectedTagihanList = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID Siswa harus berupa angka'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat tagihan: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTagihanList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih setidaknya satu tagihan untuk dibayar'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final siswaId = int.parse(_siswaIdController.text);
      final totalJumlah = selectedTagihanList.fold<double>(
          0, (sum, tagihan) => sum + tagihan.jumlah);

      final response = await apiService.submitMultiplePayments(
        siswaId,
        selectedTagihanList.map((tagihan) => tagihan.id!).toList(),
        totalJumlah,
        selectedTagihanList,
      );
      final siswaDetail = await apiService.getSiswaDetail(siswaId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            transaksi: response['transaksi'],
            siswa: siswaDetail,
          ),
        ),
      );

      _siswaIdController.clear();
      setState(() {
        tagihanBelumLunas = [];
        selectedTagihanList = [];
      });
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
            // Placeholder Logo (Ganti dengan logo resmi jika ada)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.payment,
                size: 24,
                color: Color(0xFF1976D2),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Catat Pembayaran',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lakukan Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Masukkan ID Siswa untuk melihat tagihan yang belum lunas.',
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
                            onChanged: (value) => _loadTagihanBelumLunas(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ID Siswa tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          if (_isLoading)
                            Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                              ),
                            )
                          else if (tagihanBelumLunas.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Tidak ada tagihan belum lunas',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            Column(
                              children: [
                                Text(
                                  'Pilih Tagihan untuk Dibayar:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 250,
                                  child: ListView.builder(
                                    itemCount: tagihanBelumLunas.length,
                                    itemBuilder: (context, index) {
                                      final tagihan = tagihanBelumLunas[index];
                                      final isSelected = selectedTagihanList.contains(tagihan);
                                      return Card(
                                        elevation: 3,
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(
                                            '${tagihan.jenisTagihan ?? 'Tidak Diketahui'} - ${tagihan.periode ?? 'Tidak Diketahui'}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Rp ${tagihan.jumlah.toStringAsFixed(0)}',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          value: isSelected,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedTagihanList.add(tagihan);
                                              } else {
                                                selectedTagihanList.remove(tagihan);
                                              }
                                            });
                                          },
                                          activeColor: Color(0xFF1976D2),
                                          checkColor: Colors.white,
                                          tileColor: isSelected
                                              ? Color(0xFF4FC3F7).withOpacity(0.2)
                                              : null,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Color(0xFF1976D2).withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Pembayaran:',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1976D2),
                                          ),
                                        ),
                                        Text(
                                          'Rp ${selectedTagihanList.fold<double>(0, (sum, tagihan) => sum + tagihan.jumlah).toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1976D2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                          )
                        : ElevatedButton.icon(
                            onPressed: _submitPayment,
                            icon: Icon(Icons.payment, color: Colors.white),
                            label: Text(
                              'Submit Pembayaran',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}