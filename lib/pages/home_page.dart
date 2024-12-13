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
  String selectedYear = DateTime.now().year.toString();

  Map<String, String> notes = {};
  late int currentMonth;
  late int currentYear;

  switchView() {
    setState(() {
      if (isFrontView) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  Future<void> saveNoteToFirestore(String date, String note) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('Tidak ada koneksi internet. Catatan tidak dapat disimpan.');
      return;
    }

    try {
      var uuid = Uuid();
      String noteId = uuid.v4();

      await _firestore.collection('note').doc(noteId).set({
        'id': noteId,
        'judul': note.isNotEmpty ? note : 'No Title',
        'isi': 'Diary isi default',
        'tanggal': Timestamp.now(),
        'date': date.isNotEmpty ? date : '',
      });
      
      setState(() {
        notes[date] = note;
      });
      debugPrint('Catatan berhasil disimpan: $note');
    } catch (e) {
      debugPrint('Error saat menyimpan data ke Firestore: $e');
    }
  }

  Future<void> loadNotesFromFirestore() async {
    try {
      final querySnapshot = await _firestore.collection('note').get();
      setState(() {
        for (var doc in querySnapshot.docs) {
          var data = doc.data();
          var date = data['date'] as String?;
          var judul = data['judul'] as String?;
          if (date != null && judul != null) {
            notes[date] = judul;
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }
  
  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now().month;
    currentYear = DateTime.now().year;
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    loadNotesFromFirestore();
  }

  void showEditPopup(String dateStr, String judul) {
    final TextEditingController noteController = TextEditingController();
    noteController.text = judul;

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
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  saveNoteToFirestore(dateStr, noteController.text);
                  Navigator.of(context).pop();
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

  void navigateToFirestoreTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirestoreTestPage()),
    );
  }

  void updateMonthAndYear(String year) {
    setState(() {
      selectedYear = year;
      currentYear = int.parse(year);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MenuIcon(
                    navigateToFirestoreTestPage: navigateToFirestoreTestPage,  // Memberikan parameter yang dibutuhkan
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            DropdownButton<String>(
              value: selectedYear,
              dropdownColor: Colors.white,
              items: List.generate(5, (index) {
                int year = DateTime.now().year - 2 + index;
                return DropdownMenuItem(
                  value: year.toString(),
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  updateMonthAndYear(value);
                }
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
                            ? FrontView(
                                monthIndex: currentMonth,
                                year: currentYear,
                              )
                            : Transform(
                                transform: Matrix4.rotationY(pi),
                                alignment: Alignment.center,
                                child: BackView(
                                  showEditPopup: showEditPopup,
                                  notes: notes,
                                  saveNoteToFirestore: saveNoteToFirestore,
                                  currentMonth: currentMonth,
                                  currentYear: currentYear,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
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