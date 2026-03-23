import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("KrakFlow"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("KrakFlow"),
              SizedBox(height: 10),
              Text("Organizacja studiów"),
              SizedBox(height: 10),
              Text("Dzisiejsze zadania"),
            ],
          ),
        ),
      ),
    );
  }
}