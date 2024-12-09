import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

final CollectionReference note = FirebaseFirestore.instance.collection('note'); // Koleksi 'note'

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  State<FirestoreTestPage> createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  // Controller untuk input data
  final TextEditingController _isiDiaryController = TextEditingController();
  final TextEditingController _updateIdController = TextEditingController();
  final TextEditingController _deleteIdController = TextEditingController();

  // 🔥 Fungsi CRUD (pindahkan ke dalam _FirestoreTestPageState)
  Future<void> addData(String isiDiary) async {
    try {
      final String uniqueId = const Uuid().v4(); // Membuat ID unik menggunakan UUID
      await note.doc(uniqueId).set({
        'id': uniqueId, // ID yang dihasilkan dari UUID
        'isi': isiDiary, // Data diary dari input user
        'tanggal': DateTime.now() // Tanggal saat ini
      });
      debugPrint('Data berhasil ditambahkan');
    } catch (e) {
      debugPrint('Gagal menambah data: $e');
    }
  }

  Future<void> readData() async {
    try {
      QuerySnapshot snapshot = await note.get();
      for (var doc in snapshot.docs) {
        debugPrint('Data ditemukan: ${doc.data()}');
      }
    } catch (e) {
      debugPrint('Gagal membaca data: $e');
    }
  }

  Future<void> updateData(String docId, String isiDiaryBaru) async {
    try {
      await note.doc(docId).update({
        'isi': isiDiaryBaru, // Memperbarui hanya bagian isi diary
        'tanggal': DateTime.now() // Memperbarui tanggal dengan waktu saat ini
      });
      debugPrint('Data berhasil diperbarui');
    } catch (e) {
      debugPrint('Gagal memperbarui data: $e');
    }
  }

  Future<void> deleteData(String docId) async {
    try {
      await note.doc(docId).delete();
      debugPrint('Data berhasil dihapus');
    } catch (e) {
      debugPrint('Gagal menghapus data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tes Firestore CRUD'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _isiDiaryController,
              decoration: const InputDecoration(labelText: 'Isi Diary'),
            ),
            ElevatedButton(
              onPressed: () => addData(_isiDiaryController.text), // ✅ Pemanggilan fungsi benar
              child: const Text('Tambah Data'),
            ),
            ElevatedButton(
              onPressed: readData, // ✅ Pemanggilan fungsi benar
              child: const Text('Baca Data'),
            ),
            const Divider(),
            TextField(
              controller: _updateIdController,
              decoration: const InputDecoration(labelText: 'ID yang akan diupdate'),
            ),
            TextField(
              controller: _isiDiaryController,
              decoration: const InputDecoration(labelText: 'Isi Diary Baru'),
            ),
            ElevatedButton(
              onPressed: () => updateData(_updateIdController.text, _isiDiaryController.text), // ✅ Pemanggilan fungsi benar
              child: const Text('Perbarui Data'),
            ),
            const Divider(),
            TextField(
              controller: _deleteIdController,
              decoration: const InputDecoration(labelText: 'ID yang akan dihapus'),
            ),
            ElevatedButton(
              onPressed: () => deleteData(_deleteIdController.text), // ✅ Pemanggilan fungsi benar
              child: const Text('Hapus Data'),
            ),
          ],
        ),
      ),
    );
  }
}
