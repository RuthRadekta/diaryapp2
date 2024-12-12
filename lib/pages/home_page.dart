import 'dart:math';
import 'package:diaryapp2/widgets/menu_icon.dart';
import 'package:flutter/material.dart';
import 'package:diaryapp2/widgets/front_view.dart';
import 'package:diaryapp2/widgets/back_view.dart';
import 'package:diaryapp2/widgets/action_buttons.dart';
import 'package:diaryapp2/firestore_test_page.dart'; // Import your FirestoreTestPage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool isFrontView = true;
  late AnimationController controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedYear = '2024';

  // Map untuk menyimpan catatan berdasarkan tanggal
  Map<String, String> notes = {};

  late String selectedDate;

  switchView() {
    setState(() {
      if (isFrontView) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  // Simpan catatan ke Firestore
  Future<void> saveNoteToFirestore(String date, String note) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('Tidak ada koneksi internet. Catatan tidak dapat disimpan.');
      return;
    }

    try {
      // Gunakan UUID untuk membuat ID unik untuk setiap catatan
      var uuid = Uuid();
      String noteId = uuid.v4(); // ID unik untuk catatan

      // Simpan catatan menggunakan UUID sebagai ID
      await _firestore.collection('note').doc(noteId).set({
        'id': noteId, // ID unik catatan
        'judul': note.isNotEmpty ? note : 'No Title', // Judul catatan
        'isi': 'Diary isi default', // Isi diary (dapat diubah jika ada input untuk ini)
        'tanggal': Timestamp.now(), // Tanggal saat ini
        'date': date.isNotEmpty ? date : '', // Format date untuk identifikasi tambahan
      });
      
      setState(() {
        notes[date] = note;
      });
      debugPrint('Catatan berhasil disimpan: $note');
    } catch (e) {
      debugPrint('Error saat menyimpan data ke Firestore: $e');
    }
  }

  // Baca semua catatan dari Firestore
  Future<void> loadNotesFromFirestore() async {
    final querySnapshot = await _firestore.collection('note').get();
    setState(() {
      for (var doc in querySnapshot.docs) {
        var date = doc.data()['date'];
        var note = doc.data()['note'];
        if (note != null) {
        // Cek apakah date atau note adalah null
        if (date != null && note != null) {
          notes[date] = note as String; // Pastikan 'note' adalah String
        } else {
          debugPrint('Data tidak lengkap: $date atau $note');
          }
        }
      }
    });
  }
  
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    loadNotesFromFirestore(); // Load notes on startup
  }

  // Fungsi untuk menampilkan popup edit dan menyimpan catatan
  void showEditPopup(String dateStr, String judul) {
  final TextEditingController noteController = TextEditingController();
  noteController.text = judul; // Pre-fill dengan judul jika ada

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Tambah Catatan: $dateStr"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: "Tuliskan sesuatu",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup popup
            },
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                saveNoteToFirestore(dateStr, noteController.text); // Simpan catatan
                Navigator.of(context).pop(); // Tutup popup
              } else {
                debugPrint('Judul tidak boleh kosong!');
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      );
    },
  );
}

// Fungsi untuk menavigasi ke FirestoreTestPage dan menampilkan popup edit
void navigateToFirestoreTestPage() {
  // Menampilkan popup edit sebelum navigasi
  //showEditPopup("OCT 11/2022");

  // Navigasi ke halaman FirestoreTestPage setelah popup ditutup
  //Future.delayed(const Duration(seconds: 1), () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirestoreTestPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Ganti SearchAndMenu dengan SearchIcon dan MenuIcon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  MenuIcon(),   // Menambahkan widget MenuIcon
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            // Dropdown untuk memilih tahun
            DropdownButton<String>(
              value: selectedYear,
              dropdownColor: Colors.white,
              items: List.generate(10, (index) {
                int year = 2024 + index;
                return DropdownMenuItem(
                  value: year.toString(),
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  selectedYear = value!;
                });
              },
            ),
            const SizedBox(height: 30.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 22.0),
                child: PageView.builder(
                  controller: PageController(
                    initialPage: 0,
                    viewportFraction: 0.78,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 1,
                  itemBuilder: (_, i) => AnimatedBuilder(
                    animation: controller,
                    builder: (_, child) {
                      if (controller.value >= 0.5) {
                        isFrontView = false;
                      } else {
                        isFrontView = true;
                      }

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(controller.value * pi),
                        alignment: Alignment.center,
                        child: isFrontView
                            ? FrontView(monthIndex: i + 1)
                            : Transform(
                              transform: Matrix4.rotationY(pi),
                              alignment: Alignment.center,
                              child: BackView(
                                showEditPopup: showEditPopup,
                                notes: notes,
                                saveNoteToFirestore: saveNoteToFirestore,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            // ActionButtons untuk interaksi lebih lanjut
            ActionButtons(
              showEditPopup: showEditPopup,
              change: switchView,
              navigateToFirestoreTestPage: navigateToFirestoreTestPage,
            ),
            const SizedBox(height: 75.0),
          ],
        ),
      ),
    );
  }
}