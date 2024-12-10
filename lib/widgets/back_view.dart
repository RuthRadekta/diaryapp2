import 'package:flutter/material.dart';
import '../constants.dart';
import 'action_buttons.dart';

class BackView extends StatefulWidget {
  final int monthIndex;
  final Function showEditPopup;
  final Map<String, String> notes; // Menambahkan notes ke BackView

  const BackView({
    Key? key,
    required this.monthIndex,
    required this.showEditPopup,
    required this.notes,
  }) : super(key: key);

  @override
  _BackViewState createState() => _BackViewState();
}

class _BackViewState extends State<BackView> {
  int? selectedDay;

  @override
  Widget build(BuildContext context) {
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
            Text(
              '${widget.monthIndex}',
              textScaleFactor: 2.5,
            ),
            const SizedBox(height: 5.0),
            Text(
              months[widget.monthIndex]!.keys.toList()[0],
              textScaleFactor: 2.0,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20.0),
            // Grid untuk tanggal bulan
            Expanded(
              child: GridView.builder(
                itemCount: months[widget.monthIndex]!.values.toList()[0],
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (_, i) {
                  int day = i + 1;
                  String cDay = day < 10 ? '0$day' : '$day';
                  String cMonth =
                      widget.monthIndex < 10 ? '0${widget.monthIndex}' : '${widget.monthIndex}';
                  DateTime date = DateTime.parse('2022-$cMonth-$cDay');

                  bool isSelected = selectedDay == day;
                  bool hasNote = widget.notes.containsKey('$cDay-$cMonth');

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                        String dateStr = '$cDay-$cMonth'; // Format tanggal
                        widget.showEditPopup(dateStr); // Panggil popup untuk tanggal tertentu
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue : Colors.transparent,
                        border: hasNote
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Text(
                        '$day',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: date.weekday == DateTime.sunday
                              ? Colors.red
                              : date.weekday == DateTime.saturday
                                  ? Colors.blue
                                  : Colors.black,
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
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
