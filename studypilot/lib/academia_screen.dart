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

  Treino({
    required this.nome,
    required this.subtitulo,
    required this.exercicios,
    required this.corDestaque,
  });
}

// --- TELA PRINCIPAL DA ACADEMIA ---
class AcademiaScreen extends StatefulWidget {
  const AcademiaScreen({super.key});

  @override
  State<AcademiaScreen> createState() => _AcademiaScreenState();
}

class _AcademiaScreenState extends State<AcademiaScreen> {
  // BIBLIOTECA COM ÍCONES MELHORADOS (Mantendo a sua estrutura original)
  final List<ExercicioBase> biblioteca = [
    // PEITO
    ExercicioBase("Supino Reto", "Peito", Icons.horizontal_distribute_rounded),
    ExercicioBase("Supino Inclinado", "Peito", Icons.unfold_less_double_rounded),
    ExercicioBase("Crucifixo Máquina", "Peito", Icons.compare_arrows_rounded),
    ExercicioBase("Cross Over", "Peito", Icons.center_focus_strong_rounded),
    // COSTAS
    ExercicioBase("Puxada Alta", "Costas", Icons.vertical_align_bottom_rounded),
    ExercicioBase("Remada Curvada", "Costas", Icons.line_weight_rounded),
    ExercicioBase("Remada Baixa", "Costas", Icons.reorder_rounded),
    ExercicioBase("Pull Down", "Costas", Icons.south_rounded),
    // PERNAS
    ExercicioBase("Agachamento Livre", "Pernas", Icons.keyboard_double_arrow_down_rounded),
    ExercicioBase("Leg Press 45", "Pernas", Icons.layers_rounded),
    ExercicioBase("Extensora", "Pernas", Icons.airline_seat_legroom_extra_rounded),
    ExercicioBase("Flexora", "Pernas", Icons.airline_seat_recline_extra_rounded),
    ExercicioBase("Cadeira Abdutora", "Pernas", Icons.open_in_full_rounded),
    ExercicioBase("Panturrilha em Pé", "Pernas", Icons.expand_less_rounded),
    // BRAÇOS
    ExercicioBase("Rosca Direta", "Braços", Icons.fitness_center_rounded),
    ExercicioBase("Rosca Martelo", "Braços", Icons.handyman_rounded),
    ExercicioBase("Tríceps Pulley", "Braços", Icons.arrow_downward_rounded),
    ExercicioBase("Tríceps Testa", "Braços", Icons.psychology_alt_rounded),
    // OMBROS
    ExercicioBase("Desenvolvimento", "Ombros", Icons.upload_rounded),
    ExercicioBase("Elevação Lateral", "Ombros", Icons.open_in_full_rounded),
  ];

  late List<Treino> meusTreinos;

  @override
  void initState() {
    super.initState();
    meusTreinos = [
      Treino(
        nome: "TREINO A",
        subtitulo: "Peito, Ombro e Tríceps",
        corDestaque: Colors.cyanAccent,
        exercicios: [
          ExercicioConfigurado(base: biblioteca[0]),
          ExercicioConfigurado(base: biblioteca[18]),
          ExercicioConfigurado(base: biblioteca[16]),
        ],
      ),
      Treino(
        nome: "TREINO B",
        subtitulo: "Costas e Bíceps",
        corDestaque: Colors.purpleAccent,
        exercicios: [
          ExercicioConfigurado(base: biblioteca[4]),
          ExercicioConfigurado(base: biblioteca[6]),
          ExercicioConfigurado(base: biblioteca[14]),
        ],
      ),
      Treino(
        nome: "TREINO C",
        subtitulo: "Pernas Completo",
        corDestaque: Colors.orangeAccent,
        exercicios: [
          ExercicioConfigurado(base: biblioteca[8]),
          ExercicioConfigurado(base: biblioteca[9]),
          ExercicioConfigurado(base: biblioteca[13]),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F111A),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text("WORKOUT",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      fontSize: 24,
                      color: Colors.white)),
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
          ),
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
        label: const Text("NOVO TREINO",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            colors: [
              treino.corDestaque.withOpacity(0.6),
              treino.corDestaque.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: const DecorationImage(
            image: NetworkImage(
                "https://www.transparenttextures.com/patterns/carbon-fibre.png"),
            repeat: ImageRepeat.repeat,
            opacity: 0.1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -10,
              child: Icon(Icons.fitness_center,
                  size: 120, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(treino.nome,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70)),
                  Text(treino.subtitulo.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _badge("${treino.exercicios.length} exercícios"),
                      const SizedBox(width: 8),
                      _badge("Foco: ${treino.subtitulo.split(' ')[0]}"),
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
      decoration: BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showNovoTreinoModal() {
    final cont = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F2D),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("NOMEAR NOVO TREINO",
                style:
                    TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: cont,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  hintText: "Ex: Treino D - Cardio",
                  hintStyle: TextStyle(color: Colors.white24)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (cont.text.isNotEmpty) {
                  setState(() {
                    meusTreinos.add(Treino(
                        nome: "TREINO EXTRA",
                        subtitulo: cont.text,
                        corDestaque: Colors.orangeAccent,
                        exercicios: []));
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50)),
              child: const Text("CRIAR", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _abrirTreino(Treino treino) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaginaExecucaoTreino(
                treino: treino, biblioteca: biblioteca)));
  }
}

// --- TELA DE EXECUÇÃO (AGORA COM REORDENAR) ---
class PaginaExecucaoTreino extends StatefulWidget {
  final Treino treino;
  final List<ExercicioBase> biblioteca;
  const PaginaExecucaoTreino(
      {super.key, required this.treino, required this.biblioteca});

  @override
  State<PaginaExecucaoTreino> createState() => _PaginaExecucaoTreinoState();
}

class _PaginaExecucaoTreinoState extends State<PaginaExecucaoTreino> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        title: Text(widget.treino.subtitulo,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_box_outlined, color: Colors.amber),
              onPressed: _addExercicioDaBiblioteca),
        ],
      ),
      // TROCADO: ListView por ReorderableListView para permitir arrastar
      body: widget.treino.exercicios.isEmpty
          ? const Center(
              child: Text("Adicione exercícios no +",
                  style: TextStyle(color: Colors.white24)))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: widget.treino.exercicios.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = widget.treino.exercicios.removeAt(oldIndex);
                  widget.treino.exercicios.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final ex = widget.treino.exercicios[index];
                // É necessário uma Key única para cada item ao usar ReorderableListView
                return _buildExercicioItem(ex, index, ValueKey(ex.hashCode + index));
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1F2D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              minimumSize: const Size(double.infinity, 50)),
          child: const Text("CONCLUIR TREINO",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Widget do item mantendo TODA a sua lógica de inputs e checkbox
  Widget _buildExercicioItem(ExercicioConfigurado ex, int index, Key key) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFF1C1F2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: ex.feito ? Colors.amber.withOpacity(0.5) : Colors.transparent)),
      child: Column(
        children: [
          Row(
            children: [
              // Ícone de "Drag" para indicar que pode arrastar
              const Icon(Icons.drag_indicator, color: Colors.white24, size: 20),
              const SizedBox(width: 10),
              Icon(ex.base.icone, color: Colors.amber, size: 28),
              const SizedBox(width: 15),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.base.nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                  Text(ex.base.grupo,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white38)),
                ],
              )),
              IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white24, size: 20),
                  onPressed: () =>
                      setState(() => widget.treino.exercicios.removeAt(index))),
            ],
          ),
          const Divider(color: Colors.white10, height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _colInput("Séries", ex.series.toString(),
                  (v) => ex.series = int.tryParse(v) ?? 0),
              _colInput("Reps", ex.reps, (v) => ex.reps = v),
              _colInput("Carga (kg)", ex.carga.toString(),
                  (v) => ex.carga = double.tryParse(v) ?? 0),
              Column(
                children: [
                  const Text("Feito",
                      style: TextStyle(fontSize: 10, color: Colors.white38)),
                  Checkbox(
                      value: ex.feito,
                      activeColor: Colors.amber,
                      checkColor: Colors.black,
                      onChanged: (v) => setState(() => ex.feito = v!)),
                ],
              )
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
          width: 60,
          child: TextFormField(
            initialValue: value,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
            decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10))),
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("BIBLIOTECA DE EXERCÍCIOS",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.biblioteca.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(widget.biblioteca[index].icone, color: Colors.amber),
                title: Text(widget.biblioteca[index].nome,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(widget.biblioteca[index].grupo,
                    style: const TextStyle(color: Colors.white38)),
                onTap: () {
                  setState(() {
                    widget.treino.exercicios.add(
                        ExercicioConfigurado(base: widget.biblioteca[index]));
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}