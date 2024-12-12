import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class DetailPage extends StatefulWidget {
  final String id;
  final String judul;
  final String isi;
  final DateTime tanggal;

  const DetailPage({
    super.key,
    required this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _judulController;
  late TextEditingController _isiController;
  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data diary yang diterima dari halaman sebelumnya
    _judulController = TextEditingController(text: widget.judul);
    _isiController = TextEditingController(text: widget.isi);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  // Fungsi untuk update data diary di Firestore
  Future<void> _updateDiary(String id, String judulBaru, String isiBaru) async {
    try {
      await FirebaseFirestore.instance.collection('note').doc(id).update({
        'judul': judulBaru, // Update judul
        'isi': isiBaru, // Update isi diary
        'tanggal': DateTime.now(), // Update tanggal ke waktu sekarang
      });
      debugPrint('Diary berhasil diperbarui.');
    } catch (e) {
      debugPrint('Gagal memperbarui diary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(widget.tanggal);

    return Scaffold(
      backgroundColor: const Color(0xFF004AAD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Diary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await _updateDiary(widget.id, _judulController.text, _isiController.text);
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
            TextField(
              controller: _judulController,
              maxLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Judul diary...',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedDate,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _isiController,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Tulis sesuatu di sini...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
