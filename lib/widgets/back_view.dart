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
  final int currentMonth;
  final int currentYear;

  const BackView({
    Key? key,
    required this.showEditPopup,
    required this.notes,
    required this.saveNoteToFirestore,
    required this.currentMonth,
    required this.currentYear,
  }) : super(key: key);

  @override
  _BackViewState createState() => _BackViewState();
}

final TextEditingController _judulController = TextEditingController();

class _BackViewState extends State<BackView> {
  late DateTime _currentDate;
  late int _selectedDay;
  late int _currentMonth;
  late int _currentYear;
  Map<String, bool> noteExist = {};

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _currentMonth = widget.currentMonth;
    _currentYear = widget.currentYear;
    _selectedDay = _currentDate.day;
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      QuerySnapshot querySnapshot = await note.get();
      setState(() {
        noteExist.clear();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          if (data.containsKey('tanggal')) {
            Timestamp timestamp = data['tanggal'] as Timestamp;
            DateTime noteDate = timestamp.toDate();
            String dateKey = '${noteDate.day}-${noteDate.month}-${noteDate.year}';
            debugPrint('Loaded note for date: $dateKey');
            noteExist[dateKey] = true;
          } else if (data.containsKey('date')) {
            String dateStr = data['date'] as String;
            if (dateStr.isNotEmpty) {
              List<String> dateParts = dateStr.split('-');
              if (dateParts.length == 2) {
                String day = dateParts[0];
                String month = dateParts[1];
                String dateKey = '$day-$month-$_currentYear';
                debugPrint('Loaded note from date string: $dateKey');
                noteExist[dateKey] = true;
              }
            }
          }
        }
      });
      debugPrint('All notes dates: ${noteExist.keys.toString()}');
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }

  @override
  void didUpdateWidget(BackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth || 
        oldWidget.currentYear != widget.currentYear ||
        oldWidget.notes != widget.notes) {
      setState(() {
        _currentMonth = widget.currentMonth;
        _currentYear = widget.currentYear;
      });
      _loadNotes();
    }
  }

  void _showDiaryDialog(int day, int month) {
    String formattedDay = day < 10 ? '0$day' : '$day';
    String formattedMonth = month < 10 ? '0$month' : '$month';
    String monthName = months[month]!.keys.first;
    String dateStr = '$formattedDay-$formattedMonth';
    String displayDate = '$formattedDay $monthName $_currentYear';
    _judulController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Masukkan Judul Diary untuk $displayDate'),
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
                  await widget.saveNoteToFirestore(dateStr, _judulController.text);
                  await _loadNotes();
                  Navigator.pop(context);
                  
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          id: const Uuid().v4(),
                          judul: _judulController.text,
                          isi: '',
                          tanggal: DateTime(_currentYear, month, day),
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
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

  List<DateTime> _getDaysInMonth() {
    List<DateTime> days = [];
    
    // Dapatkan tanggal pertama bulan ini
    DateTime firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    
    // Sesuaikan weekday agar Minggu = 0 (dalam DateTime.weekday, Minggu = 7)
    int firstWeekday = firstDayOfMonth.weekday % 7;
    
    // Tambahkan tanggal dari bulan sebelumnya
    DateTime lastMonth = DateTime(_currentYear, _currentMonth - 1);
    int daysInLastMonth = _daysInMonth(_currentMonth - 1, _currentYear);
    for (int i = 0; i < firstWeekday; i++) {
      days.insert(0, DateTime(lastMonth.year, lastMonth.month, daysInLastMonth - i));
    }
    
    // Tambahkan tanggal untuk bulan ini
    for (int i = 1; i <= _daysInMonth(_currentMonth, _currentYear); i++) {
      days.add(DateTime(_currentYear, _currentMonth, i));
    }
    
    // Tambahkan tanggal untuk bulan depan jika diperlukan
    int remainingDays = 42 - days.length; // 42 = 6 baris x 7 hari
    DateTime nextMonth = DateTime(_currentYear, _currentMonth + 1);
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(nextMonth.year, nextMonth.month, i));
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    int daysInCurrentMonth = _daysInMonth(_currentMonth, _currentYear);
    DateTime firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    
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
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  '${months[_currentMonth]!.keys.first}-$_currentYear',
                  textScaleFactor: 2.0,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _changeMonth(1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Tambahkan fungsi search di sini
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Sun', style: TextStyle(color: Colors.red)),
                Text('Mon'),
                Text('Tue'),
                Text('Wed'),
                Text('Thu'),
                Text('Fri'),
                Text('Sat'),
              ],
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: GridView.builder(
                itemCount: 42,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (_, i) {
                  DateTime currentDate = _getDaysInMonth()[i];
                  int day = currentDate.day;
                  bool isCurrentMonth = currentDate.month == _currentMonth;
                  bool isToday = currentDate.year == DateTime.now().year &&
                      currentDate.month == DateTime.now().month &&
                      currentDate.day == DateTime.now().day;
                  bool isSelected = isCurrentMonth && _selectedDay == day;
                  
                  String dateKey = '${currentDate.day}-${currentDate.month}-${currentDate.year}';
                  bool hasNote = noteExist[dateKey] ?? false;
                  
                  if (hasNote) {
                    debugPrint('Found note for date: $dateKey');
                  }
                  
                  bool isSunday = currentDate.weekday == DateTime.sunday;

                  return GestureDetector(
                    onTap: () {
                      if (isCurrentMonth) {
                        setState(() {
                          _selectedDay = day;
                          _showDiaryDialog(day, _currentMonth);
                        });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday && isCurrentMonth
                            ? const Color(0xFF004AAD)
                            : isSelected && isCurrentMonth
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.transparent,
                        border: hasNote && isCurrentMonth
                            ? Border.all(color: Colors.green, width: 2)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              color: !isCurrentMonth 
                                  ? Colors.grey.withOpacity(0.5)
                                  : isToday
                                      ? Colors.white
                                      : isSunday 
                                          ? Colors.red
                                          : Colors.black,
                              fontWeight: (isSelected || isToday) && isCurrentMonth 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                          if (hasNote && isCurrentMonth)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
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
