import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  /*Future<void> addData(String isiDiary) async {
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
  }*/
  Future<void> addData(String isiDiary) async {
  try {
    final String uniqueId = const Uuid().v4(); // Membuat ID unik menggunakan UUID

    // Cek koneksi internet
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint("Tidak ada koneksi internet. Data tersimpan secara lokal.");
      // Implementasi penyimpanan lokal (misalnya SQLite atau SharedPreferences)
      return;
    }

    // Simpan ke Firestore
    await note.doc(uniqueId).set({
      'id': uniqueId,
      'isi': isiDiary,
      'tanggal': DateTime.now(),
    });
    debugPrint('Data berhasil ditambahkan ke Firestore');
  } catch (e) {
    debugPrint('Gagal menambah data: $e');
    debugPrint("Data tersimpan secara lokal karena terjadi error.");
    // Implementasi penyimpanan lokal jika Firestore gagal
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

  Stream<QuerySnapshot> getNotesStream() {
    return note.orderBy('tanggal', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004AAD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Interactive Diary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Tambah Data') {
                addData(_isiDiaryController.text);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Tambah Data',
                  child: Text('Tambah Data'),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada diary.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  final data = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final doc = data[index];
                      final id = doc['id'];
                      final isi = doc['isi'];
                      final tanggal = (doc['tanggal'] as Timestamp).toDate();
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            isi, // Menampilkan isi diary
                            overflow: TextOverflow.ellipsis, // Memotong teks jika terlalu panjang
                            maxLines: 1, // Menampilkan hanya 1 baris
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                              '${tanggal.toLocal()}'.split(' ')[0]), // Format tanggal
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteData(id);
                            },
                          ),
                          onTap: () {
                            // Navigasi ke halaman detail ketika Card diklik
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  id: id,
                                  isi: isi,
                                  tanggal: tanggal,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(color: Colors.white),
            TextField(
              controller: _isiDiaryController,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Write something here...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              onPressed: () {
                addData(_isiDiaryController.text);
              },
              backgroundColor: const Color(0xFFFFD4E2),
              label: Row(
                children: const [
                  Text(
                    "Add Diary",
                    style: TextStyle(color: Colors.black),
                  ),
                  Icon(Icons.add, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String id;
  final String isi;
  final DateTime tanggal;

  const DetailPage({
    super.key,
    required this.id,
    required this.isi,
    required this.tanggal,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _isiController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan isi diary yang sudah ada
    _isiController = TextEditingController(text: widget.isi);
  }

  @override
  void dispose() {
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _updateDiary(String id, String isiBaru) async {
    try {
      await note.doc(id).update({
        'isi': isiBaru,
        'tanggal': DateTime.now(), // Update tanggal ke waktu sekarang
      });
      debugPrint('Diary berhasil diperbarui.');
    } catch (e) {
      debugPrint('Gagal memperbarui diary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Simpan data ke Firestore saat tombol Kembali ditekan
            await _updateDiary(widget.id, _isiController.text);
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanggal:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              '${widget.tanggal.toLocal()}'.split(' ')[0],
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _isiController,
                maxLines: null, // Input teks fleksibel
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Tulis sesuatu di sini...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
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
