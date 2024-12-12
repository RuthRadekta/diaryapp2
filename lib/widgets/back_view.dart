import 'package:diaryapp2/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaryapp2/pages/home_page.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants.dart';
import 'action_buttons.dart';

final CollectionReference note = FirebaseFirestore.instance.collection('note');

class BackView extends StatefulWidget {
  final Function showEditPopup;
  final Map<String, String> notes;
  final Function saveNoteToFirestore;

  const BackView({
    Key? key,
    required this.showEditPopup,
    required this.notes,
    required this.saveNoteToFirestore,
  }) : super(key: key);

  @override
  _BackViewState createState() => _BackViewState();
}

final TextEditingController _judulController = TextEditingController();

class _BackViewState extends State<BackView> {
  DateTime _currentDate = DateTime.now(); // Tanggal saat ini
  int _selectedDay = 0;
  late int _currentMonth;
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    _currentMonth = _currentDate.month; // Bulan saat ini
    _currentYear = _currentDate.year; // Tahun saat ini
    _selectedDay = _currentDate.day; // Hari saat ini
  }

  void _showDiaryDialog(int day, int month) {
    String cDay = day < 10 ? '0$day' : '$day';
    String cMonth = month < 10 ? '0$month' : '$month';
    String dateStr = '$cDay-$cMonth';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Judul Diary'),
          content: TextField(
            controller: _judulController,
            decoration: const InputDecoration(hintText: 'Masukkan judul...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (_judulController.text.isNotEmpty) {
                  var uuid = Uuid();
                  String noteId = uuid.v4();

                  await widget.saveNoteToFirestore(dateStr, _judulController.text);
                  setState(() {
                    _judulController.clear();
                  });
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        id: noteId,
                        judul: _judulController.text,
                        isi: '',
                        tanggal: DateTime.now(),
                      ),
                    ),
                  );
                } else {
                  debugPrint('Judul tidak boleh kosong!');
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  int _daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth += direction;
      if (_currentMonth > 12) {
        _currentMonth = 1;
        _currentYear++;
      } else if (_currentMonth < 1) {
        _currentMonth = 12;
        _currentYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysInCurrentMonth = _daysInMonth(_currentMonth, _currentYear);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8.0),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  '${_currentMonth}-${_currentYear}',
                  textScaleFactor: 2.0,
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: GridView.builder(
                itemCount: daysInCurrentMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (_, i) {
                  int day = i + 1;
                  bool isToday = _currentDate.day == day &&
                      _currentMonth == _currentDate.month &&
                      _currentYear == _currentDate.year;
                  bool isSelected = _selectedDay == day;
                  bool hasNote = widget.notes.containsKey('$day-$_currentMonth');

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                        _showDiaryDialog(day, _currentMonth);
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.blue
                            : isToday
                                ? Colors.orange
                                : Colors.transparent,
                        border: hasNote
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Text(
              'Select a date to write',
              textScaleFactor: 0.8,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
