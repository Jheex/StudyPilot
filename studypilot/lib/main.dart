import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_data.dart'; 
import 'study_screen.dart';
import 'agenda_screen.dart';
import 'financas_screen.dart';
import 'academia_screen.dart';
import 'compras_screen.dart';
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
  final AppData appData = AppData(); 

  @override
  void initState() {
    super.initState();
    appData.loadData();
    appData.addListener(_atualizarInterface);
  }

  @override
  void dispose() {
    appData.removeListener(_atualizarInterface);
    super.dispose();
  }

  void _atualizarInterface() {
    if (mounted) setState(() {});
  }

  void mudarAba(int index) {
    setState(() => indiceAtual = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> telas = [
      buildDashboard(),
      const AgendaScreen(),
      const FinancasScreen(),
      const StudyScreen(),
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
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05), // CORRIGIDO
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.settings_outlined, size: 22, color: kAccentColor),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.05), // CORRIGIDO
            height: 1
          ),
        ),
      ),
      body: IndexedStack(index: indiceAtual, children: telas),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kBackgroundColor,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: NavigationBar(
          backgroundColor: kBackgroundColor,
          indicatorColor: kAccentColor.withValues(alpha: 0.1),
          selectedIndex: indiceAtual,
          onDestinationSelected: mudarAba,
          height: 75,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.calendar_today_rounded), label: 'Agenda'),
            NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Finanças'),
            NavigationDestination(icon: Icon(Icons.bolt_rounded), label: 'Estudos'),
          ],
        ),
      ),
    );
  }

  // --- DASHBOARD ---

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

        _buildQuickAccessGrid(), // Onde estão os 6 cards novos

        const SizedBox(height: 30),
        
        // 1º AGENDA
        _buildSectionHeader("AGENDA: PRAZOS RECENTES", Icons.event_note_rounded),
        _buildAgendaPreview(),

        const SizedBox(height: 25),

        // 2º FINANÇAS
        _buildSectionHeader("FINANÇAS: VISÃO MENSAL", Icons.account_balance_wallet_rounded),
        _buildFinancasSummary(),

        const SizedBox(height: 25),

        // 3º ESTUDOS
        _buildSectionHeader("ESTUDOS: PERFORMANCE POR PASTA", Icons.leaderboard_rounded),
        _buildEstudosRanking(),
        
        const SizedBox(height: 30),
      ],
    ),
  );
}

Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white24),
          const SizedBox(width: 8),
          // REMOVIDO O 'const' DAQUI:
          Text(
            title, 
            style: const TextStyle(
              fontSize: 10, 
              color: Colors.white24, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.1
            )
          ),
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
      childAspectRatio: 2.1,
      children: [
        // Ordem: Agenda, Finanças, Estudos
        _buildSmallCard("Agenda", const Color(0xFFCF6679), Icons.calendar_today_rounded, () => mudarAba(1)),
        _buildSmallCard("Finanças", kSecondaryColor, Icons.payments_rounded, () => mudarAba(2)),
        _buildSmallCard("Estudos", kAccentColor, Icons.bolt_rounded, () => mudarAba(3)),
        
        // Novos cards abrindo telas externas
        _buildSmallCard("Academia", Colors.orangeAccent, Icons.fitness_center_rounded, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AcademiaScreen()));
        }),
        _buildSmallCard("Compras", Colors.lightBlueAccent, Icons.shopping_cart_rounded, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ComprasScreen()));
        }),
        
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)), // CORRIGIDO
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
    final proximasTarefas = appData.tarefas
        .where((t) => !t.concluido)
        .take(3) 
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(22)),
      child: proximasTarefas.isEmpty
          ? const Center(child: Text("Nenhuma missão pendente! 🚀", style: TextStyle(color: Colors.white38, fontSize: 12)))
          : Column(
              children: proximasTarefas.map((t) {
                bool isLast = proximasTarefas.last == t;
                return Column(
                  children: [
                    _buildAgendaItem(
                      t.titulo, 
                      "${t.dataHora.day}/${t.dataHora.month}", 
                      t.categoria.cor 
                    ),
                    if (!isLast) const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white10, height: 1),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildAgendaItem(String task, String date, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 12),
        Expanded(child: Text(task, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
        Text(date, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildEstudosRanking() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(22)),
      child: appData.pastas.isEmpty
          ? const Center(child: Text("Sem dados de estudo.", style: TextStyle(color: Colors.white30, fontSize: 12)))
          : Column(
              children: appData.pastas.map((p) {
                final stats = LevelCalculator.getStats(p.totalXP);
                final double progressoReal = stats['barra'];
                final int levelAtual = stats['level'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${p.nome} (Lvl $levelAtual)", style: const TextStyle(fontSize: 12, color: Colors.white70), overflow: TextOverflow.ellipsis)),
                          Text("${(progressoReal * 100).toInt()}%", style: TextStyle(color: p.cor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressoReal, 
                          backgroundColor: Colors.white.withValues(alpha: 0.05), // CORRIGIDO
                          color: p.cor, 
                          minHeight: 6
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildFinancasSummary() {
    double totalGastos = appData.categoriasGastos.values.fold(0, (sum, item) => sum + item);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kSecondaryColor.withValues(alpha: 0.1)), // CORRIGIDO
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("GASTOS TOTAIS NO MÊS", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                "R\$ ${totalGastos.toStringAsFixed(2)}", 
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kSecondaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), // CORRIGIDO
            child: const Icon(Icons.trending_down, color: kSecondaryColor, size: 20),
          ),
        ],
      ),
    );
  }
}