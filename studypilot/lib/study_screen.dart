import 'package:flutter/material.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final List<String> _categorias = ["TUDO", "FIAP", "ALURA", "BRADESCO", "CISCO", "FISK", "AUTO"];
  String _categoriaSelecionada = "TUDO";

  final List<Map<String, dynamic>> _materias = [
    {
      'id': '1',
      'origem': 'ALURA',
      'nome': 'Python',
      'cor': const Color(0xFF3776AB),
      'logs': [
        {'texto': 'Variáveis e Tipos', 'data': '20/02'},
      ],
    },
  ];

  final TextEditingController _nomeController = TextEditingController();
  // Removi o aviso de "prefer_final_fields" alterando aqui conforme necessário
  String _origemSelecionada = "FIAP";

  Map<String, dynamic> _calcularLevel(List logs) {
    int xpTotal = logs.length * 100;
    int xpPorLevel = 500; 
    int level = (xpTotal / xpPorLevel).floor() + 1;
    double progressoBarra = (xpTotal % xpPorLevel) / xpPorLevel;
    
    return {
      'level': level,
      'xpAtual': xpTotal % xpPorLevel,
      'xpProx': xpPorLevel,
      'barra': progressoBarra,
      'totalGeral': xpTotal
    };
  }

  void _salvarMateria() {
    if (_nomeController.text.isEmpty) return;
    setState(() {
      _materias.add({
        'id': DateTime.now().toString(),
        'origem': _origemSelecionada,
        'nome': _nomeController.text,
        'cor': _getCorPorOrigem(_origemSelecionada),
        'logs': [],
      });
    });
    _nomeController.clear();
    Navigator.pop(context);
  }

  Color _getCorPorOrigem(String origem) {
    switch (origem) {
      case 'FIAP': return const Color(0xFFED145B);
      case 'ALURA': return const Color(0xFF167BF7);
      case 'CISCO': return const Color(0xFF049FD9);
      case 'BRADESCO': return const Color(0xFFFBAD17);
      case 'FISK': return const Color(0xFFFF0000);
      default: return const Color(0xFFBB86FC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaFiltrada = _categoriaSelecionada == "TUDO" 
        ? _materias 
        : _materias.where((m) => m['origem'] == _categoriaSelecionada).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        title: const Text("Track de Estudos", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: _categorias.map((cat) {
                bool isSelected = _categoriaSelecionada == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _categoriaSelecionada = cat),
                    selectedColor: const Color(0xFFBB86FC),
                    labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: listaFiltrada.length,
              itemBuilder: (context, index) => _buildXPCard(listaFiltrada[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFBB86FC),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildXPCard(Map<String, dynamic> item) {
    var stats = _calcularLevel(item['logs']);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailScreen(curso: item)));
        setState(() {}); 
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['origem'], style: TextStyle(color: item['cor'], fontWeight: FontWeight.bold, fontSize: 10)),
                    Text(item['nome'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("LVL ${stats['level']}", style: TextStyle(color: item['cor'], fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: stats['barra'],
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                color: item['cor'],
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 25, right: 25, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Nova Skill", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: const Color(0xFF0A0C10), borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String>(
                  value: _origemSelecionada,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _categorias.where((c) => c != "TUDO").map((String v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (val) => setModalState(() => _origemSelecionada = val!),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  hintText: "O que você vai estudar?",
                  filled: true,
                  fillColor: const Color(0xFF0A0C10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _salvarMateria,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBB86FC)),
                  child: const Text("INICIAR TRACKING", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> curso;
  const CourseDetailScreen({super.key, required this.curso});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final TextEditingController _logController = TextEditingController();
  
  void _registrarLog() {
    if (_logController.text.isEmpty) return;
    setState(() {
      (widget.curso['logs'] as List).insert(0, {
        'texto': _logController.text,
        'data': "${DateTime.now().day}/${DateTime.now().month}"
      });
    });
    _logController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(title: Text(widget.curso['nome']), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _logController,
                    decoration: InputDecoration(
                      hintText: "Registro de evolução (+100 XP)",
                      filled: true,
                      fillColor: const Color(0xFF161B22),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _registrarLog, 
                  icon: const Icon(Icons.bolt),
                  style: IconButton.styleFrom(backgroundColor: widget.curso['cor']),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: (widget.curso['logs'] as List).length,
              itemBuilder: (context, index) {
                final log = widget.curso['logs'][index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      Text(log['data'], style: TextStyle(color: widget.curso['cor'], fontWeight: FontWeight.bold, fontSize: 10)),
                      const SizedBox(width: 15),
                      Expanded(child: Text(log['texto'])),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}