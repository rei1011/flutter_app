import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.menu_book),
            title: Text("manga list"),
          ),
        ],
      ),
    );
  }
}
