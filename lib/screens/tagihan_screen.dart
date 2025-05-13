import 'package:flutter/material.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tagihanList = apiService.getTagihan();
  }

  void _addTagihan() async {
    setState(() => _isLoading = true);
    try {
      await apiService.createTagihan(
        int.parse(_siswaIdController.text),
        _jenisTagihanController.text,
        double.parse(_jumlahController.text),
        _periodeController.text,
      );
      setState(() {
        tagihanList = apiService.getTagihan();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tagihan berhasil ditambahkan')),
      );
      _siswaIdController.clear();
      _jenisTagihanController.clear();
      _jumlahController.clear();
      _periodeController.clear();
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
      appBar: AppBar(title: Text('Kelola Tagihan')),
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
              controller: _jenisTagihanController,
              decoration: InputDecoration(labelText: 'Jenis Tagihan (SPP/LKS)'),
            ),
            TextField(
              controller: _jumlahController,
              decoration: InputDecoration(labelText: 'Jumlah Tagihan (Rp)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _periodeController,
              decoration: InputDecoration(labelText: 'Periode (contoh: April 2025)'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addTagihan,
                    child: Text('Tambah Tagihan'),
                  ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Tagihan>>(
                future: tagihanList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada tagihan'));
                  }

                  final tagihan = snapshot.data!;
                  return ListView.builder(
                    itemCount: tagihan.length,
                    itemBuilder: (context, index) {
                      final item = tagihan[index];
                      return ListTile(
                        title: Text('${item.jenisTagihan ?? 'Tidak Diketahui'} - ${item.periode ?? 'Tidak Diketahui'}'),
                        subtitle: Text('Rp ${item.jumlah.toStringAsFixed(0)} - ${item.lunas ? "Lunas" : "Belum Lunas"}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}