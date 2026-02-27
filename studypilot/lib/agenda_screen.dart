import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retornamos Column e não Scaffold porque o main já tem o Scaffold
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PRÓXIMOS PRAZOS", 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFCF6679), letterSpacing: 2)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildAgendaItem("Entrega de Challenge", "FIAP - Fase 3", "Amanhã", const Color(0xFFCF6679)),
                _buildAgendaItem("Checkpoint Python", "FIAP - Global", "Em 3 dias", Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaItem(String title, String sub, String date, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: color),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Text(date, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}