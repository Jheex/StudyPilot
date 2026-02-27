import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'study_screen.dart';
import 'agenda_screen.dart';
import 'financas_screen.dart';
import 'config_screen.dart';

// Constantes Globais de Estilo
const Color kBackgroundColor = Color(0xFF121421);
const Color kCardColor = Color(0xFF1C1F33);
const Color kAccentColor = Color(0xFFBB86FC);
const Color kSecondaryColor = Color(0xFF03DAC6);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const StudyPilotApp());
}

class StudyPilotApp extends StatelessWidget {
  const StudyPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyPilot',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccentColor,
          brightness: Brightness.dark,
          primary: kAccentColor,
          surface: kCardColor,
        ),
      ),
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

  void mudarAba(int index) {
    setState(() => indiceAtual = index);
  }

  @override
  Widget build(BuildContext context) {
    // Definimos as telas aqui
    final List<Widget> telas = [
      buildDashboard(),
      const StudyScreen(),
      const AgendaScreen(), // Agora a Agenda gerencia seu próprio botão interno
      const FinancasScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kAccentColor, kSecondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text("🚀", style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "StudyPilot",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "OPERATIONAL UNIT",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 5),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfigScreen())
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_outlined, size: 22, color: kAccentColor),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white.withAlpha(13), height: 1),
        ),
      ),
      body: IndexedStack(
        index: indiceAtual,
        children: telas,
      ),
      // BOTÃO FLUTUANTE REMOVIDO DAQUI
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kBackgroundColor,
          border: Border(top: BorderSide(color: Colors.white.withAlpha(13))),
        ),
        child: NavigationBar(
          backgroundColor: kBackgroundColor,
          indicatorColor: kAccentColor.withAlpha(26),
          selectedIndex: indiceAtual,
          onDestinationSelected: mudarAba,
          height: 75,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.bolt_rounded), label: 'Estudos'),
            NavigationDestination(icon: Icon(Icons.calendar_today_rounded), label: 'Agenda'),
            NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Finanças'),
          ],
        ),
      ),
    );
  }

  Widget buildDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CENTRAL DE OPERAÇÕES",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kSecondaryColor, letterSpacing: 2)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              children: [
                _buildBlock("Estudos", "XP & Níveis", Icons.bolt_rounded, kAccentColor, () => mudarAba(1)),
                _buildBlock("Agenda", "Prazos FIAP", Icons.calendar_today_rounded, const Color(0xFFCF6679), () => mudarAba(2)),
                _buildBlock("Finanças", "Balanço", Icons.payments_rounded, kSecondaryColor, () => mudarAba(3)),
                _buildBlock("Alarmes", "Foco Total", Icons.alarm_rounded, Colors.orangeAccent, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withAlpha(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(sub, style: const TextStyle(color: Colors.white30, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}