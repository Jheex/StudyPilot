import 'package:flutter/material.dart';

class FinancasScreen extends StatelessWidget {
  const FinancasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SAÚDE FINANCEIRA", 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 2)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.greenAccent.withOpacity(0.1), Colors.transparent]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Saldo Disponível", style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text("R\$ 2.450,00", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("ÚLTIMAS MOVIMENTAÇÕES", style: TextStyle(fontSize: 12, color: Colors.white38)),
          // Aqui poderias listar gastos como Alura, Mensalidade FIAP, etc.
        ],
      ),
    );
  }
}