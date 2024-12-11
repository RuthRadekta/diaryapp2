import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';

final CollectionReference note = FirebaseFirestore.instance.collection('note'); // Koleksi 'note'

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  State<FirestoreTestPage> createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  // Controller untuk input data
  final TextEditingController _isiDiaryController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _updateIdController = TextEditingController();
  final TextEditingController _deleteIdController = TextEditingController();

  // 🔥 Fungsi CRUD (pindahkan ke dalam _FirestoreTestPageState)
  Future<void> addData(String judul, String isiDiary) async {
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
      'judul': judul, // Tambahkan judul
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
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController _judulDialogController =
                        TextEditingController();
                    final TextEditingController _isiDialogController =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text('Tambah Diary'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _judulDialogController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan judul...',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _isiDialogController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan isi...',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_judulDialogController.text.isNotEmpty &&
                                _isiDialogController.text.isNotEmpty) {
                              addData(
                                _judulDialogController.text,
                                _isiDialogController.text,
                              );
                              Navigator.pop(context);
                            } else {
                              debugPrint('Judul dan isi tidak boleh kosong!');
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ],
                    );
                  },
                );
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
                      
                      // Memastikan data tidak null dan kemudian melakukan pengecekan 'judul'
                      final docData = doc.data() as Map<String, dynamic>?;
                      final judul = docData != null && docData.containsKey('judul') ? docData['judul'] : 'No Title'; // Pengecekan field 'judul'

                      final tanggal = (doc['tanggal'] as Timestamp).toDate();
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            judul, // Menampilkan hanya judul
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Hapus Diary'),
                                    content: const Text('Apakah Anda yakin ingin menghapus diary ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Menutup dialog jika "No"
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deleteData(id); // Hapus data jika "Yes"
                                          Navigator.pop(context); // Menutup dialog
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          onTap: () {
                            // Navigasi ke halaman detail ketika Card diklik
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  id: id,
                                  judul: judul, // Kirim judul ke halaman detail
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
              controller: _judulController,
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
                if (_judulController.text.isNotEmpty) {
                  addData(_judulController.text, _isiDiaryController.text);
                  _judulController.clear();
                  _isiDiaryController.clear();
                } else {
                  debugPrint('Judul atau isi tidak boleh kosong!');
                }
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
    // Inisialisasi controller dengan isi diary yang sudah ada
     _judulController = TextEditingController(text: widget.judul);
    _isiController = TextEditingController(text: widget.isi);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _updateDiary(String id, String judulBaru, String isiBaru) async {
  try {
    await note.doc(id).update({
      'judul': judulBaru, // Update judul
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
    // Format tanggal untuk menampilkan dalam format yang diinginkan
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
                focusedBorder: InputBorder.none
              ),
            ),
            const SizedBox(height: 5),
            // Menampilkan tanggal dalam format italic
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
                maxLines: null, // Input teks fleksibel
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
