import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _siswaIdController = TextEditingController();
  final _jumlahController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  void _submitPayment() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.submitPayment(
        int.parse(_siswaIdController.text),
        double.parse(_jumlahController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran berhasil: Sisa tagihan Rp ${response['sisa_tagihan']}')),
      );
      _siswaIdController.clear();
      _jumlahController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catat Pembayaran')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _siswaIdController,
              decoration: InputDecoration(labelText: 'ID Siswa'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _jumlahController,
              decoration: InputDecoration(labelText: 'Jumlah Pembayaran (Rp)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitPayment,
                    child: Text('Submit Pembayaran'),
                  ),
          ],
        ),
      ),
    );
  }
}