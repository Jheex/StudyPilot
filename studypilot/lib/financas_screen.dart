import 'package:flutter/material.dart';

class FinancasScreen extends StatelessWidget {
  const FinancasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SAÚDE FINANCEIRA", 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 2)),
          const SizedBox(height: 20),
          
          // CARD DE SALDO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              // CORREÇÃO: Usando .withValues em vez de .withOpacity
              gradient: LinearGradient(
                colors: [Colors.greenAccent.withValues(alpha: 0.1), Colors.transparent]
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.1)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Saldo Disponível", style: TextStyle(color: Colors.white38, fontSize: 12)),
                SizedBox(height: 5),
                Text("R\$ 2.450,00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          const Text("GASTOS POR CATEGORIA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 20),

          // GRÁFICO SIMPLES
          _buildSimpleChart("Educação", 0.7, Colors.blueAccent),
          _buildSimpleChart("Lazer", 0.3, Colors.orangeAccent),
          _buildSimpleChart("Assinaturas", 0.15, Colors.purpleAccent),
          
          const Spacer(),
          
          // DICA DO DIA
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                SizedBox(width: 15),
                Expanded(
                  child: Text("Sua mensalidade da FIAP vence em 5 dias. Programe o pagamento!", 
                    style: TextStyle(fontSize: 11, color: Colors.white60)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSimpleChart(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
              Text("${(percent * 100).toInt()}%", style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}