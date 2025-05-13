import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../models/siswa.dart';

class ReceiptScreen extends StatelessWidget {
  final Transaksi transaksi;
  final Siswa siswa;

  ReceiptScreen({required this.transaksi, required this.siswa});

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Kwitansi Pembayaran',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Nama Siswa: ${siswa.user.name ?? siswa.nama ?? 'Unknown'}'),
              pw.Text('Kelas: ${siswa.kelas ?? 'Tidak Diketahui'}'),
              pw.Text('NIS: ${siswa.nis ?? 'Tidak Diketahui'}'),
              pw.Text('Jumlah Tagihan Dibayar: ${transaksi.jumlahTagihanDibayar ?? 1}'),
              pw.Text('Detail Tagihan: ${transaksi.jenisTagihan ?? 'Tidak Diketahui'}'),
              pw.Text('Periode: ${transaksi.periode ?? 'Tidak Diketahui'}'),
              pw.Text('Total Jumlah: Rp ${transaksi.jumlah.toStringAsFixed(0)}'),
              pw.Text('Tanggal Pembayaran: ${DateFormat('dd MMMM yyyy, HH:mm').format(transaksi.tanggalBayar.toLocal())}'), // Gunakan toLocal()
              pw.Text('Petugas: ${transaksi.petugas.name}'),
              pw.Text('Status: ${transaksi.status}'),
              pw.SizedBox(height: 20),
              pw.Text('Terima kasih telah melakukan pembayaran!'),
            ],
          ),
        ),
      ),
    );

    return await pdf.save();
  }

  Future<void> _generateAndDownloadPDF(BuildContext context) async {
    try {
      final pdfData = await _generatePdf();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/kwitansi_${transaksi.id}.pdf');
      await file.writeAsBytes(pdfData);

      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kwitansi telah diunduh!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat kwitansi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _printPDF(BuildContext context) async {
    try {
      final pdfData = await _generatePdf();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencetak kwitansi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bukti Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Kwitansi Pembayaran',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Nama Siswa: ${siswa.user.name ?? siswa.nama ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
                Text('Kelas: ${siswa.kelas ?? 'Tidak Diketahui'}', style: TextStyle(fontSize: 16)),
                Text('NIS: ${siswa.nis ?? 'Tidak Diketahui'}', style: TextStyle(fontSize: 16)),
                Text('Jumlah Tagihan Dibayar: ${transaksi.jumlahTagihanDibayar ?? 1}', style: TextStyle(fontSize: 16)),
                Text('Detail Tagihan: ${transaksi.jenisTagihan ?? 'Tidak Diketahui'}', style: TextStyle(fontSize: 16)),
                Text('Periode: ${transaksi.periode ?? 'Tidak Diketahui'}', style: TextStyle(fontSize: 16)),
                Text('Total Jumlah: Rp ${transaksi.jumlah.toStringAsFixed(0)}', style: TextStyle(fontSize: 16)),
                Text(
                  'Tanggal Pembayaran: ${DateFormat('dd MMMM yyyy, HH:mm').format(transaksi.tanggalBayar.toLocal())}', // Gunakan toLocal()
                  style: TextStyle(fontSize: 16),
                ),
                Text('Petugas: ${transaksi.petugas.name}', style: TextStyle(fontSize: 16)),
                Text('Status: ${transaksi.status}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 30),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _generateAndDownloadPDF(context),
                        icon: Icon(Icons.download),
                        label: Text('Unduh Kwitansi (PDF)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () => _printPDF(context),
                        icon: Icon(Icons.print),
                        label: Text('Print Kwitansi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
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