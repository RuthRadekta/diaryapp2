import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diaryapp2/pages/detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

  // Koleksi 'note' di Firestore
final CollectionReference note = FirebaseFirestore.instance.collection('note');

Future<void> addData(String judul, String isiDiary) async {
  try {
    // Cek koneksi internet
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint("Tidak ada koneksi internet. Data tersimpan secara lokal.");
      // Implementasi penyimpanan lokal jika perlu
      return;
    }

    // Pastikan data yang dikirimkan tidak kosong
    if (judul.isEmpty || isiDiary.isEmpty) {
      debugPrint("Judul atau Isi Diary tidak boleh kosong");
      return; // Hindari menambah data kosong
    }

    // Membuat unique ID dengan UUID
    final String uniqueId = const Uuid().v4();
    debugPrint('Generated unique ID: $uniqueId');

    // Simpan ke Firestore, gunakan add() agar Firestore membuat ID otomatis
    await note.add({
      'id': uniqueId,  // Jika ingin menggunakan UUID
      'judul': judul,
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

Future<void> _createDiary(String judulBaru, String isiBaru) async {
  try {
    final newDoc = await note.add({
      'judul': judulBaru.isEmpty ? 'Diary Baru' : judulBaru, // Jika judul kosong, gunakan 'Diary Baru'
      'isi': isiBaru,
      'tanggal': DateTime.now(), // Menyimpan waktu saat ini sebagai tanggal
    });
    debugPrint('Diary berhasil dibuat dengan ID: ${newDoc.id}');
  } catch (e) {
    debugPrint('Gagal membuat diary: $e');
  }
}


class ActionButtons extends StatefulWidget {
  final Function showEditPopup;
  final Function change;
  final Function navigateToFirestoreTestPage;

  const ActionButtons({
    super.key,
    required this.showEditPopup,
    required this.change,
    required this.navigateToFirestoreTestPage,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool isFront = true;

  // Fungsi untuk mendapatkan tanggal hari ini
  String getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('MMM dd/yyyy').format(now);
  }

  // Fungsi untuk menentukan ikon sesuai dengan waktu
  IconData getCurrentTimeIcon() {
    int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny_rounded; // Pagi
    } else if (hour >= 12 && hour < 16) {
      return Icons.wb_sunny; // Siang
    } else if (hour >= 16 && hour < 19) {
      return Icons.wb_twilight; // Sore
    } else {
      return Icons.nightlight_round; // Malam
    }
  }

  // Fungsi untuk mendapatkan teks deskripsi waktu
  String getCurrentTimeDescription() {
    int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 16) {
      return 'Afternoon';
    } else if (hour >= 16 && hour < 19) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Container(
            width: 155.0,
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon sesuai dengan waktu saat ini
                Icon(getCurrentTimeIcon()),
                const SizedBox(width: 10.0),
                // Today details (deskripsi waktu dan tanggal)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getCurrentTimeDescription(), // Deskripsi waktu
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        getCurrentDate(), // Tanggal dinamis
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Tombol edit
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(
                    id: '',
                    judul: '',
                    isi: '',
                    tanggal: DateTime.now(),
                  ),
                ),
              );
            },
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mode_edit_outlined,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          // Tombol toggle
          GestureDetector(
            onTap: () {
              widget.change(); // Fungsi change
              setState(() {
                isFront = !isFront;
              });
            },
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: isFront ? Colors.black87 : const Color(0xFF033495),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFront ? Icons.calendar_month_rounded : Icons.undo_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
