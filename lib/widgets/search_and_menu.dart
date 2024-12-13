import 'package:flutter/material.dart';

class SearchAndMenu extends StatefulWidget {
  final Function navigateToFirestoreTestPage;

  const SearchAndMenu({
    Key? key,
    required this.navigateToFirestoreTestPage,
  }) : super(key: key);

  @override
  _SearchAndMenuState createState() => _SearchAndMenuState();
}

class _SearchAndMenuState extends State<SearchAndMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
            iconSize: 30.0,
          ),
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
