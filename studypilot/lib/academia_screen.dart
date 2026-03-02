import 'package:flutter/material.dart';

class AcademiaScreen extends StatelessWidget {
  const AcademiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UNIDADE DE TREINO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121421),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("FOCO DO DIA", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F33),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: const Text("🏋️ Musculação - Peito e Tríceps", style: TextStyle(fontSize: 18)),
            ),
            // Aqui você pode adicionar um ListView com os exercícios
          ],
        ),
      ),
    );
  }
}