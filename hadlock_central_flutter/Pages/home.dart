import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _customizations =
      <({Color foregroundColor, Color backgroundColor, ShapeBorder shape})>[
        (
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
        ),
        (
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        (
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          shape: StadiumBorder(),
        ),
      ];

  int _index = 0;

  void _showNextCustomization() {
    setState(() {
      _index = (_index + 1) % _customizations.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customization = _customizations[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('FloatingActionButton Sample')),
      body: const Center(child: Text('Indie stinks!')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNextCustomization,
        foregroundColor: customization.foregroundColor,
        backgroundColor: customization.backgroundColor,
        shape: customization.shape,
        tooltip: 'Change button style',
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
