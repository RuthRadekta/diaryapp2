import 'package:flutter/material.dart';

class MenuIcon extends StatefulWidget {
  final Function navigateToFirestoreTestPage;

  const MenuIcon({
    Key? key,
    required this.navigateToFirestoreTestPage,
  }) : super(key: key);

  @override
  _MenuIconState createState() => _MenuIconState();
}

class _MenuIconState extends State<MenuIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              widget.navigateToFirestoreTestPage(); // Mengakses melalui "widget."
            },
            icon: const Icon(Icons.short_text_rounded),
            iconSize: 30.0,
          ),
        ],
      ),
    );
  }
}
