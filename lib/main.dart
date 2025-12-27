import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dclicactivite2avance/screens/endroitsinterface.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MonApplication(),
    ),
  );
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mes endroits préférés',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false, // Cette ligne enlève la bannière
      home: const EndroitsInterface(),
    );
  }
}
