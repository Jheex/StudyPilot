import 'package:flutter/material.dart';
import 'study_screen.dart';
import 'agenda_screen.dart';   // Novo import
import 'financas_screen.dart'; // Novo import

void main() => runApp(const StudyPilotApp());

class StudyPilotApp extends StatelessWidget {
  const StudyPilotApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, scaffoldBackgroundColor: const Color(0xFF0A0C10)),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int indiceAtual = 0;

  void mudarAba(int index) => setState(() => indiceAtual = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> telas = [
      buildDashboard(),       // Aba 0
      const StudyScreen(),    // Aba 1
      const AgendaScreen(),   // Aba 2
      const FinancasScreen(), // Aba 3
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("StudyPilot", style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: IndexedStack(index: indiceAtual, children: telas),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0A0C10),
        indicatorColor: const Color(0xFFBB86FC).withOpacity(0.2),
        selectedIndex: indiceAtual,
        onDestinationSelected: mudarAba,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bolt_rounded), label: 'Estudos'),
          NavigationDestination(icon: Icon(Icons.calendar_today_rounded), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.payments_rounded), label: 'Finanças'),
        ],
      ),
    );
  }

  Widget buildDashboard() {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildBlock("Estudos", "XP & Nível", Icons.bolt_rounded, const Color(0xFFBB86FC), () => mudarAba(1)),
        _buildBlock("Agenda", "Prazos", Icons.calendar_today_rounded, const Color(0xFFCF6679), () => mudarAba(2)),
        _buildBlock("Finanças", "Controlo", Icons.payments_rounded, Colors.greenAccent, () => mudarAba(3)),
        _buildBlock("Alarmes", "Foco", Icons.alarm_rounded, const Color(0xFF03DAC6), () {}),
      ],
    );
  }

  Widget _buildBlock(String t, String s, IconData i, Color c, VoidCallback o) {
    return InkWell(
      onTap: o,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(i, color: c, size: 30),
            const SizedBox(height: 10),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(s, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}