import 'package:flutter/material.dart';

class DynamicLinkPage extends StatelessWidget {
  const DynamicLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World DeepLink'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
