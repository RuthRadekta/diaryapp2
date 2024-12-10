import 'dart:math';
import 'package:flutter/material.dart';
import 'package:diaryapp2/widgets/search_and_menu.dart';
import 'package:diaryapp2/widgets/front_view.dart';
import 'package:diaryapp2/widgets/back_view.dart';
import 'package:diaryapp2/widgets/action_buttons.dart';
import 'package:diaryapp2/firestore_test_page.dart'; // Import your FirestoreTestPage
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool isFrontView = true;
  late AnimationController controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    await _firestore.collection('notes').doc(date).set({'note': note});
    setState(() {
      notes[date] = note;
    });
  }

  // Baca semua catatan dari Firestore
  Future<void> loadNotesFromFirestore() async {
    final querySnapshot = await _firestore.collection('notes').get();
    setState(() {
      for (var doc in querySnapshot.docs) {
        notes[doc.id] = doc.data()['note'];
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
  void showEditPopup(String dateStr) {
  final TextEditingController noteController = TextEditingController();

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
              saveNoteToFirestore(dateStr, noteController.text); // Simpan ke Firestore
              Navigator.of(context).pop(); // Tutup popup
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
            const SearchAndMenu(),
            const SizedBox(height: 30.0),
            DropdownButton(
              value: '2024',
              items: const [
                DropdownMenuItem(value: '2024', child: Text('2024'))
              ],
              onChanged: (value) {},
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
                  itemCount: 12,
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
                                  monthIndex: i + 1,
                                  showEditPopup: showEditPopup, // Pass the function here
                                  notes: notes,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            // Pass the navigate function to ActionButtons
            ActionButtons(
              showEditPopup: showEditPopup,
              change: switchView,
              navigateToFirestoreTestPage: navigateToFirestoreTestPage, // Pass the function here
            ),
            const SizedBox(height: 75.0),
          ],
        ),
      ),
    );
  }
}
