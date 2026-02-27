import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELOS DE DADOS ---

class EstudoLog {
  String texto;
  final String data;
  final int xp;

  EstudoLog({required this.texto, required this.data, this.xp = 100});

  Map<String, dynamic> toJson() => {'texto': texto, 'data': data, 'xp': xp};
  factory EstudoLog.fromJson(Map<String, dynamic> json) => 
      EstudoLog(texto: json['texto'], data: json['data'], xp: json['xp'] ?? 100);
}

class Materia {
  final String id;
  String nome;
  final List<EstudoLog> logs;

  Materia({required this.id, required this.nome, required this.logs});

  int get totalXP => logs.fold(0, (sum, log) => sum + log.xp);

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'logs': logs.map((l) => l.toJson()).toList()};
  factory Materia.fromJson(Map<String, dynamic> json) => Materia(
    id: json['id'],
    nome: json['nome'],
    logs: (json['logs'] as List).map((l) => EstudoLog.fromJson(l)).toList(),
  );
}

class PastaEstudo {
  String nome;
  Color cor;
  final List<Materia> materias;

  PastaEstudo({required this.nome, required this.cor, required this.materias});

  int get totalXP => materias.fold(0, (sum, m) => sum + m.totalXP);

  Map<String, dynamic> toJson() => {'nome': nome, 'cor': cor.value, 'materias': materias.map((m) => m.toJson()).toList()};
  factory PastaEstudo.fromJson(Map<String, dynamic> json) => PastaEstudo(
    nome: json['nome'],
    cor: Color(json['cor']),
    materias: (json['materias'] as List).map((m) => Materia.fromJson(m)).toList(),
  );
}

class LevelCalculator {
  static Map<String, dynamic> getStats(int xp) {
    int xpPorLevel = 500;
    int level = (xp / xpPorLevel).floor() + 1;
    double progresso = (xp % xpPorLevel) / xpPorLevel;
    return {'level': level, 'barra': progresso};
  }
}

// --- TELA 1: DASHBOARD DE PASTAS ---

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<PastaEstudo> _pastas = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('study_pilot_v3');
    if (data != null) {
      setState(() {
        Iterable l = jsonDecode(data);
        _pastas = l.map((model) => PastaEstudo.fromJson(model)).toList();
      });
    }
  }

  void _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('study_pilot_v3', jsonEncode(_pastas));
  }

  void _showPastaDialog({PastaEstudo? pastaParaEditar}) {
    TextEditingController nameController = TextEditingController(text: pastaParaEditar?.nome ?? "");
    Color selectedColor = pastaParaEditar?.cor ?? const Color(0xFFBB86FC);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          title: Text(pastaParaEditar == null ? "Novo Card" : "Editar Card", style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Nome da Pasta", hintStyle: TextStyle(color: Colors.white24)),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.amber, Colors.purpleAccent].map((c) {
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedColor = c),
                    child: CircleAvatar(backgroundColor: c, radius: 15, child: selectedColor == c ? const Icon(Icons.check, size: 15, color: Colors.white) : null),
                  );
                }).toList(),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    if (pastaParaEditar == null) {
                      _pastas.add(PastaEstudo(nome: nameController.text, cor: selectedColor, materias: []));
                    } else {
                      pastaParaEditar.nome = nameController.text;
                      pastaParaEditar.cor = selectedColor;
                    }
                  });
                  _salvar();
                  Navigator.pop(context);
                }
              },
              child: Text(pastaParaEditar == null ? "CRIAR" : "SALVAR"),
            )
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    int xpGlobal = _pastas.fold(0, (sum, p) => sum + p.totalXP);
    var stats = LevelCalculator.getStats(xpGlobal);
    int xpPorLevel = 500; 
    int xpAtualNoLevel = xpGlobal % xpPorLevel;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFBB86FC),
        onPressed: () => _showPastaDialog(),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF0A0C10),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(stats, xpAtualNoLevel, xpPorLevel),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 15, 
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPastaCard(_pastas[index]),
                childCount: _pastas.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map stats, int xpAtual, int totalNecessario) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1D1B26), Color(0xFF0A0C10)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            "PROGRESSO LEVEL ${stats['level']}",
            style: const TextStyle(
              color: Color(0xFFBB86FC),
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBB86FC).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: stats['barra'],
                    minHeight: 12,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBB86FC)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$xpAtual XP",
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      "$totalNecessario XP",
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastaCard(PastaEstudo pasta) {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => MateriasScreen(pasta: pasta)));
            setState(() {});
            _salvar();
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pasta.cor.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, color: pasta.cor, size: 40),
                  const SizedBox(height: 8),
                  Text(pasta.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        PositionfulMenu(
          onEdit: () => _showPastaDialog(pastaParaEditar: pasta),
          onDelete: () => setState(() { _pastas.remove(pasta); _salvar(); }),
        ),
      ],
    );
  }
}

// --- COMPONENTE DE MENU (REUTILIZÁVEL) ---

class PositionfulMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const PositionfulMenu({super.key, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5, right: 5,
      child: PopupMenuButton(
        icon: const Icon(Icons.more_vert, color: Colors.white24, size: 18),
        color: const Color(0xFF161B22),
        itemBuilder: (context) => [
          PopupMenuItem(onTap: onEdit, child: const Text("Editar", style: TextStyle(color: Colors.white))),
          PopupMenuItem(onTap: onDelete, child: const Text("Excluir", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}

// --- TELA 2: LISTA DE MATÉRIAS ---

class MateriasScreen extends StatefulWidget {
  final PastaEstudo pasta;
  const MateriasScreen({super.key, required this.pasta});

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  void _showMateriaDialog({Materia? materiaParaEditar}) {
    TextEditingController controller = TextEditingController(text: materiaParaEditar?.nome ?? "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(materiaParaEditar == null ? "Nova Skill" : "Editar Skill", style: const TextStyle(color: Colors.white)),
        content: TextField(controller: controller, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  if (materiaParaEditar == null) {
                    widget.pasta.materias.add(Materia(id: DateTime.now().toString(), nome: controller.text, logs: []));
                  } else {
                    materiaParaEditar.nome = controller.text;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text("SALVAR"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(title: Text(widget.pasta.nome), backgroundColor: Colors.transparent, foregroundColor: widget.pasta.cor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.pasta.cor,
        onPressed: () => _showMateriaDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.pasta.materias.length,
        itemBuilder: (context, index) {
          final m = widget.pasta.materias[index];
          var mStats = LevelCalculator.getStats(m.totalXP);
          return Card(
            color: const Color(0xFF161B22),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => DetalheMateriaScreen(materia: m, cor: widget.pasta.cor)));
                setState(() {});
              },
              title: Text(m.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: LinearProgressIndicator(value: mStats['barra'], backgroundColor: Colors.white10, color: widget.pasta.cor, minHeight: 2),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("LVL ${mStats['level']}", style: TextStyle(color: widget.pasta.cor, fontWeight: FontWeight.bold)),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white24),
                    itemBuilder: (context) => [
                      PopupMenuItem(onTap: () => _showMateriaDialog(materiaParaEditar: m), child: const Text("Editar")),
                      PopupMenuItem(onTap: () => setState(() => widget.pasta.materias.remove(m)), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- TELA 3: RELATÓRIOS (LOGS) ---

class DetalheMateriaScreen extends StatefulWidget {
  final Materia materia;
  final Color cor;
  const DetalheMateriaScreen({super.key, required this.materia, required this.cor});

  @override
  State<DetalheMateriaScreen> createState() => _DetalheMateriaScreenState();
}

class _DetalheMateriaScreenState extends State<DetalheMateriaScreen> {
  final TextEditingController _logController = TextEditingController();

  void _showEditLogDialog(EstudoLog log) {
    TextEditingController editController = TextEditingController(text: log.texto);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Editar Relatório", style: TextStyle(color: Colors.white)),
        content: TextField(controller: editController, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(onPressed: () {
            setState(() => log.texto = editController.text);
            Navigator.pop(context);
          }, child: const Text("SALVAR")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(title: Text(widget.materia.nome), backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: _logController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "O que aprendeu hoje?", 
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true, 
                    fillColor: const Color(0xFF161B22), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                  ),
                )),
                const SizedBox(width: 10),
                IconButton.filled(
                  icon: const Icon(Icons.bolt), 
                  style: IconButton.styleFrom(backgroundColor: widget.cor), 
                  onPressed: () {
                    if (_logController.text.isNotEmpty) {
                      setState(() => widget.materia.logs.insert(0, EstudoLog(texto: _logController.text, data: "${DateTime.now().day}/${DateTime.now().month}")));
                      _logController.clear();
                    }
                  }
                ),
              ],
            ),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.materia.logs.length,
            itemBuilder: (context, index) {
              final log = widget.materia.logs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Text(log.data, style: TextStyle(color: widget.cor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 15),
                    Expanded(child: Text(log.texto, style: const TextStyle(color: Colors.white70))),
                    PopupMenuButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white10),
                      itemBuilder: (context) => [
                        PopupMenuItem(onTap: () => _showEditLogDialog(log), child: const Text("Editar")),
                        PopupMenuItem(onTap: () => setState(() => widget.materia.logs.remove(log)), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
                      ],
                    )
                  ],
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}