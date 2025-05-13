import 'package:flutter/material.dart';
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
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat tagihan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTagihanList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih setidaknya satu tagihan untuk dibayar'),
          backgroundColor: Colors.redAccent,
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
        title: Text(
          'Catat Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lakukan Pembayaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Masukkan ID Siswa untuk melihat tagihan yang belum lunas.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 5,
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
                            labelStyle: TextStyle(color: Colors.teal.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.teal),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.teal),
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
                        tagihanBelumLunas.isEmpty
                            ? Text(
                                'Tidak ada tagihan belum lunas',
                                style: TextStyle(color: Colors.grey.shade600),
                              )
                            : Column(
                                children: [
                                  Text(
                                    'Pilih Tagihan untuk Dibayar:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: tagihanBelumLunas.length,
                                      itemBuilder: (context, index) {
                                        final tagihan = tagihanBelumLunas[index];
                                        final isSelected = selectedTagihanList.contains(tagihan);
                                        return CheckboxListTile(
                                          title: Text(
                                            '${tagihan.jenisTagihan ?? 'Tidak Diketahui'} - ${tagihan.periode ?? 'Tidak Diketahui'}',
                                            style: TextStyle(color: Colors.teal.shade900),
                                          ),
                                          subtitle: Text(
                                            'Rp ${tagihan.jumlah.toStringAsFixed(0)}',
                                            style: TextStyle(color: Colors.grey.shade600),
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
                                          activeColor: Colors.teal,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Total: Rp ${selectedTagihanList.fold<double>(0, (sum, tagihan) => sum + tagihan.jumlah).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade900,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                        )
                      : ElevatedButton.icon(
                          onPressed: _submitPayment,
                          icon: Icon(Icons.payment),
                          label: Text(
                            'Submit Pembayaran',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
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
    );
  }
}