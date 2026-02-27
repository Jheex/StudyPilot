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
    final List<Widget> telas = [
      buildDashboard(),
      const StudyScreen(),
      const AgendaScreen(),
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
                Text("StudyPilot",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: -0.5),
                ),
                Text("OPERATIONAL UNIT",
                  style: TextStyle(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigScreen())),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withAlpha(13), shape: BoxShape.circle),
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
      body: IndexedStack(index: indiceAtual, children: telas),
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

  // --- NOVA DASHBOARD ESTRUTURADA ---

  Widget buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CENTRAL DE OPERAÇÕES",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kSecondaryColor, letterSpacing: 2)),
          const SizedBox(height: 15),

          // 1. Atalhos Rápidos
          _buildQuickAccessGrid(),

          const SizedBox(height: 30),
          
          // 2. Agenda - Próximas tarefas
          _buildSectionHeader("AGENDA: PRAZOS RECENTES", Icons.event_note_rounded),
          _buildAgendaPreview(),

          const SizedBox(height: 25),

          // 3. Estudos - Ranking de XP por Pasta
          _buildSectionHeader("ESTUDOS: PERFORMANCE POR PASTA", Icons.leaderboard_rounded),
          _buildEstudosRanking(),

          const SizedBox(height: 25),

          // 4. Finanças - Resumo de Gastos
          _buildSectionHeader("FINANÇAS: VISÃO MENSAL", Icons.account_balance_wallet_rounded),
          _buildFinancasSummary(),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- COMPONENTES DA DASHBOARD ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white24),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1, // Cards mais compactos
      children: [
        _buildSmallCard("Estudos", kAccentColor, Icons.bolt_rounded, () => mudarAba(1)),
        _buildSmallCard("Agenda", const Color(0xFFCF6679), Icons.calendar_today_rounded, () => mudarAba(2)),
        _buildSmallCard("Finanças", kSecondaryColor, Icons.payments_rounded, () => mudarAba(3)),
        _buildSmallCard("Ajustes", Colors.blueGrey, Icons.settings_suggest_rounded, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigScreen()));
        }),
      ],
    );
  }

  Widget _buildSmallCard(String label, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaPreview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          _buildAgendaItem("Checkpoint 2 - Mobile", "Hoje, 23:59", Colors.redAccent),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10, height: 1),
          ),
          _buildAgendaItem("Global Solution FIAP", "Em 12 dias", Colors.amber),
        ],
      ),
    );
  }

  Widget _buildAgendaItem(String task, String date, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 12),
        Expanded(child: Text(task, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Text(date, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildEstudosRanking() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          _buildRankingItem("Desenvolvimento Cross-Platform", 0.72, kAccentColor),
          const SizedBox(height: 15),
          _buildRankingItem("Engenharia de Software", 0.35, kSecondaryColor),
        ],
      ),
    );
  }

  Widget _buildRankingItem(String pasta, double progresso, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(pasta, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            Text("${(progresso * 100).toInt()}%", style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progresso, 
            backgroundColor: Colors.white.withOpacity(0.05), 
            color: color, 
            minHeight: 6
          ),
        ),
      ],
    );
  }

  Widget _buildFinancasSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kSecondaryColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("GASTOS TOTAIS (FEVEREIRO)", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("R\$ 1.420,50", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kSecondaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.trending_down, color: kSecondaryColor, size: 20),
          ),
        ],
      ),
    );
  }
}