import 'package:flutter/material.dart';

// --- MODELOS DE DADOS ---
class ExercicioBase {
  final String nome;
  final String grupo;
  final IconData icone;
  ExercicioBase(this.nome, this.grupo, this.icone);
}

class ExercicioConfigurado {
  final ExercicioBase base;
  int series;
  String reps;
  double carga;
  bool feito;

  ExercicioConfigurado({
    required this.base,
    this.series = 3,
    this.reps = "12",
    this.carga = 0,
    this.feito = false,
  });
}

class Treino {
  final String nome;
  final String subtitulo;
  final List<ExercicioConfigurado> exercicios;
  final Color corDestaque;

  Treino({required this.nome, required this.subtitulo, required this.exercicios, required this.corDestaque});
}

// --- TELA PRINCIPAL DA ACADEMIA ---
class AcademiaScreen extends StatefulWidget {
  const AcademiaScreen({super.key});

  @override
  State<AcademiaScreen> createState() => _AcademiaScreenState();
}

class _AcademiaScreenState extends State<AcademiaScreen> {
  // Dados de exemplo (Biblioteca de exercícios)
  final List<ExercicioBase> biblioteca = [
    ExercicioBase("Supino Reto", "Peito", Icons.fitness_center),
    ExercicioBase("Agachamento Livre", "Pernas", Icons.accessibility_new),
    ExercicioBase("Puxada Alta", "Costas", Icons.format_align_center),
    ExercicioBase("Rosca Direta", "Braços", Icons.exposure_plus_1),
    ExercicioBase("Leg Press 45", "Pernas", Icons.settings_input_component),
  ];

  final List<Treino> meusTreinos = [
    Treino(
      nome: "TREINO A",
      subtitulo: "Peito e Tríceps",
      corDestaque: Colors.cyanAccent,
      exercicios: [],
    ),
    Treino(
      nome: "TREINO B",
      subtitulo: "Costas e Bíceps",
      corDestaque: Colors.purpleAccent,
      exercicios: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Dark Navy Deep
      body: CustomScrollView(
        slivers: [
          // Header Estilizado
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F111A),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text("WORKOUT", 
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 24, color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.amber.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.history, color: Colors.white54)),
              const SizedBox(width: 10),
            ],
          ),

          // Seção de Cards de Treino
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCardTreino(meusTreinos[index]),
                childCount: meusTreinos.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNovoTreinoModal,
        backgroundColor: Colors.amber,
        label: const Text("NOVO TREINO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCardTreino(Treino treino) {
    return GestureDetector(
      onTap: () => _abrirTreino(treino),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [treino.corDestaque.withOpacity(0.6), treino.corDestaque.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: const NetworkImage("https://www.transparenttextures.com/patterns/carbon-fibre.png"),
            repeat: ImageRepeat.repeat,
            opacity: 0.2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20, bottom: -10,
              child: Icon(Icons.fitness_center, size: 120, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(treino.nome, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                  Text(treino.subtitulo.toUpperCase(), 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _badge("${treino.exercicios.length} exercícios"),
                      const SizedBox(width: 8),
                      _badge("45 min"),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // --- MODAL PARA CRIAR TREINO ---
  void _showNovoTreinoModal() {
    final cont = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F2D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("NOMEAR NOVO TREINO", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: cont,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Ex: Treino C - Pernas"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if(cont.text.isNotEmpty) {
                  setState(() {
                    meusTreinos.add(Treino(nome: "TREINO", subtitulo: cont.text, corDestaque: Colors.orangeAccent, exercicios: []));
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("CRIAR"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- TELA DE EXECUÇÃO DO TREINO ---
  void _abrirTreino(Treino treino) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PaginaExecucaoTreino(treino: treino, biblioteca: biblioteca)));
  }
}

// --- TELA ONDE O TREINO ACONTECE ---
class PaginaExecucaoTreino extends StatefulWidget {
  final Treino treino;
  final List<ExercicioBase> biblioteca;
  const PaginaExecucaoTreino({super.key, required this.treino, required this.biblioteca});

  @override
  State<PaginaExecucaoTreino> createState() => _PaginaExecucaoTreinoState();
}

class _PaginaExecucaoTreinoState extends State<PaginaExecucaoTreino> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(title: Text(widget.treino.subtitulo), actions: [
        IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: _addExercicioDaBiblioteca),
      ]),
      body: widget.treino.exercicios.isEmpty 
        ? const Center(child: Text("Adicione exercícios no +", style: TextStyle(color: Colors.white24)))
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: widget.treino.exercicios.length,
            itemBuilder: (context, index) {
              final ex = widget.treino.exercicios[index];
              return _buildExercicioItem(ex, index);
            },
          ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("FINALIZAR TREINO"),
        ),
      ),
    );
  }

  Widget _buildExercicioItem(ExercicioConfigurado ex, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF1C1F2D), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(ex.base.icone, color: Colors.amber),
              const SizedBox(width: 15),
              Expanded(child: Text(ex.base.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              IconButton(icon: const Icon(Icons.delete, color: Colors.white24, size: 20), onPressed: () => setState(() => widget.treino.exercicios.removeAt(index))),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _colInput("Séries", ex.series.toString(), (v) => ex.series = int.parse(v)),
              _colInput("Reps", ex.reps, (v) => ex.reps = v),
              _colInput("Carga (kg)", ex.carga.toString(), (v) => ex.carga = double.parse(v)),
              Checkbox(value: ex.feito, activeColor: Colors.amber, checkColor: Colors.black, onChanged: (v) => setState(() => ex.feito = v!))
            ],
          )
        ],
      ),
    );
  }

  Widget _colInput(String label, String value, Function(String) onSave) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        SizedBox(
          width: 50,
          child: TextFormField(
            initialValue: value,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(4), fillColor: Colors.transparent),
            onChanged: onSave,
          ),
        )
      ],
    );
  }

  void _addExercicioDaBiblioteca() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1F2D),
      builder: (context) => ListView.builder(
        itemCount: widget.biblioteca.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(widget.biblioteca[index].icone, color: Colors.amber),
          title: Text(widget.biblioteca[index].nome),
          subtitle: Text(widget.biblioteca[index].grupo),
          onTap: () {
            setState(() {
              widget.treino.exercicios.add(ExercicioConfigurado(base: widget.biblioteca[index]));
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}