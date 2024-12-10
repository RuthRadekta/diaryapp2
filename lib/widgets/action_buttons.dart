import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              widget.navigateToFirestoreTestPage(); // Fungsi navigasi
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
