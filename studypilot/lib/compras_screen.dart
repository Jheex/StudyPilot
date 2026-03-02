import 'package:flutter/material.dart';

class ComprasScreen extends StatelessWidget {
  const ComprasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SUPRIMENTOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121421),
      ),
      body: const Center(
        child: Text("Lista de compras em desenvolvimento... 🛒", 
          style: TextStyle(color: Colors.white38)),
      ),
    );
  }
}