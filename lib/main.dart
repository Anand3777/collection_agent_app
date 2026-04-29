import 'package:flutter/material.dart';
import 'dashboard.dart';

void main() {
  runApp(const CollectionAgentApp());
}

class CollectionAgentApp extends StatelessWidget {
  const CollectionAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collection Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A1128),
        fontFamily: 'Roboto',
      ),
      home: const DashboardPage(),
    );
  }
}
