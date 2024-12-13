import 'package:flutter/material.dart';
import '../constants.dart';

class FrontView extends StatelessWidget {
  final int monthIndex;
  final int year;

  const FrontView({
    Key? key,
    required this.monthIndex,
    required this.year,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFEE5E1),
              Color(0xFF033495),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8.0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthIndex.toString(),
              textScaleFactor: 3.5,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '${months[monthIndex]!.keys.toList()[0]} $year',
              textScaleFactor: 2.5,
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5/${months[monthIndex]!.values.toList()[0]}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Container(
                        width: double.infinity,
                        height: 3.0,
                        color: Colors.white30,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 5 / 31,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 30.0,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
