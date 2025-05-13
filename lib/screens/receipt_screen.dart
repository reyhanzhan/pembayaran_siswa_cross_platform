import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
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

  // Fungsi untuk mengubah angka menjadi terbilang (dalam bahasa Indonesia)
  String _numberToWords(int number) {
    const List<String> units = [
      '', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima', 'Enam', 'Tujuh', 'Delapan', 'Sembilan'
    ];
    const List<String> teens = [
      'Sepuluh', 'Sebelas', 'Dua Belas', 'Tiga Belas', 'Empat Belas', 'Lima Belas',
      'Enam Belas', 'Tujuh Belas', 'Delapan Belas', 'Sembilan Belas'
    ];
    const List<String> tens = [
      '', '', 'Dua Puluh', 'Tiga Puluh', 'Empat Puluh', 'Lima Puluh',
      'Enam Puluh', 'Tujuh Puluh', 'Delapan Puluh', 'Sembilan Puluh'
    ];
    const List<String> thousands = ['', 'Ribu', 'Juta', 'Miliar', 'Triliun'];

    if (number == 0) return 'Nol';

    String words = '';
    int groupIndex = 0;

    while (number > 0) {
      int group = number % 1000;
      if (group > 0) {
        String groupWords = '';
        int hundreds = group ~/ 100;
        int tensAndUnits = group % 100;

        if (hundreds > 0) {
          if (hundreds == 1) {
            groupWords += 'Seratus';
          } else {
            groupWords += '${units[hundreds]} Ratus';
          }
        }

        if (tensAndUnits > 0) {
          if (groupWords.isNotEmpty) groupWords += ' ';
          if (tensAndUnits < 10) {
            groupWords += units[tensAndUnits];
          } else if (tensAndUnits < 20) {
            groupWords += teens[tensAndUnits - 10];
          } else {
            int tensDigit = tensAndUnits ~/ 10;
            int unitDigit = tensAndUnits % 10;
            groupWords += tens[tensDigit];
            if (unitDigit > 0) {
              groupWords += ' ${units[unitDigit]}';
            }
          }
        }

        if (groupWords.isNotEmpty) {
          if (words.isNotEmpty) words = '$groupWords ${thousands[groupIndex]} $words';
          else words = '$groupWords ${thousands[groupIndex]}';
        }
      }
      number ~/= 1000;
      groupIndex++;
    }

    return words.trim();
  }

  Future<Uint8List> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Menggunakan font bawaan (Helvetica)
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Konversi jumlah ke terbilang
    String terbilang = _numberToWords(transaksi.jumlah.toInt()) + ' Rupiah';

    // Muat logo dari aset
    final logoData = await rootBundle.load('assets/images/logo.jpeg');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Sekolah
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logoImage, width: 50, height: 50),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'SMK KARTINI SURABAYA',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Jl. Kartini No. 123, Surabaya',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Telp: (031) 12345678',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'No. ${transaksi.id}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Surabaya, ${dateFormat.format(transaksi.tanggalBayar.toLocal())}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(thickness: 1, color: PdfColors.black),

            // Judul Kwitansi
            pw.Center(
              child: pw.Text(
                'KWITANSI',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.SizedBox(height: 16),

            // Konten Utama: Informasi Siswa
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Telah diterima dari',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 50), // Jarak ke tanda titik dua
                pw.Text(
                  ':',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '${siswa.user.name ?? siswa.nama ?? 'Unknown'}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NIS',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 95), // Jarak ke tanda titik dua
                pw.Text(
                  ':',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '${siswa.nis ?? 'Tidak Diketahui'}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Kelas',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 85), // Jarak ke tanda titik dua
                pw.Text(
                  ':',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '${siswa.kelas ?? 'Tidak Diketahui'}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Uang sejumlah',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 40), // Jarak ke tanda titik dua
                pw.Text(
                  ':',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '$terbilang',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 40), // Jarak ke tanda titik dua
                pw.Text(
                  '',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  'Rp ${transaksi.jumlah.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Untuk pembayaran',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 45), // Jarak ke tanda titik dua
                pw.Text(
                  ':',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '${transaksi.jenisTagihan ?? 'Tidak Diketahui'} (${transaksi.periode ?? 'Tidak Diketahui'})',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Jumlah Tagihan Dibayar',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 20), // Jarak ke tanda titik dua
                pw.Text(
                  ':',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '${transaksi.jumlahTagihanDibayar ?? 1}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(thickness: 1, color: PdfColors.black),

            // Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(width: 0),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Surabaya, ${dateFormat.format(transaksi.tanggalBayar.toLocal())}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 40),
                    pw.Text(
                      '( ${transaksi.petugas.name} )',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return await pdf.save();
  }

  Future<void> _generateAndDownloadPDF(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuat dan mengunduh kwitansi...'),
        backgroundColor: Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
    try {
      final pdfData = await _generatePdf(context);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/kwitansi_${transaksi.id}.pdf');
      await file.writeAsBytes(pdfData);

      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kwitansi telah diunduh!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat kwitansi: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _printPDF(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mencetak kwitansi...'),
        backgroundColor: Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
    try {
      final pdfData = await _generatePdf(context);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencetak kwitansi: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    // Konversi jumlah ke terbilang
    String terbilang = _numberToWords(transaksi.jumlah.toInt()) + ' Rupiah';

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
                Icons.receipt,
                size: 24,
                color: Color(0xFF1976D2),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Bukti Pembayaran',
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
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Sekolah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo.jpeg',
                        width: 50,
                        height: 50,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'SMK KARTINI SURABAYA',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Jl. Kartini No. 123, Surabaya',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Telp: (031) 12345678',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'No. ${transaksi.id}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Surabaya, ${dateFormat.format(transaksi.tanggalBayar.toLocal())}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 30,
                  ),

                  // Judul Kwitansi
                  Center(
                    child: Text(
                      'KWITANSI',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Konten Utama: Informasi Siswa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Telah diterima dari',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 50), // Jarak ke tanda titik dua
                      Text(
                        ':',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${siswa.user.name ?? siswa.nama ?? 'Unknown'}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NIS',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 95), // Jarak ke tanda titik dua
                      Text(
                        ':',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${siswa.nis ?? 'Tidak Diketahui'}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelas',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 85), // Jarak ke tanda titik dua
                      Text(
                        ':',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${siswa.kelas ?? 'Tidak Diketahui'}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uang sejumlah',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 40), // Jarak ke tanda titik dua
                      Text(
                        ':',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '$terbilang',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 40), // Jarak ke tanda titik dua
                      Text(
                        '',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Rp ${transaksi.jumlah.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Untuk pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 45), // Jarak ke tanda titik dua
                      Text(
                        ':',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${transaksi.jenisTagihan ?? 'Tidak Diketahui'} (${transaksi.periode ?? 'Tidak Diketahui'})',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Tagihan Dibayar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 20), // Jarak ke tanda titik dua
                      Text(
                        ':',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${transaksi.jumlahTagihanDibayar ?? 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 30,
                  ),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Surabaya, ${dateFormat.format(transaksi.tanggalBayar.toLocal())}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            '( ${transaksi.petugas.name} )',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Tombol Aksi
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _generateAndDownloadPDF(context),
                          icon: Icon(Icons.download, color: Colors.white),
                          label: Text(
                            'Unduh Kwitansi (PDF)',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1976D2),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: () => _printPDF(context),
                          icon: Icon(Icons.print, color: Colors.white),
                          label: Text(
                            'Print Kwitansi',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1976D2),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}