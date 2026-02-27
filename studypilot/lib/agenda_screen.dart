import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELOS ---

class Categoria {
  String nome;
  Color cor;
  Categoria({required this.nome, required this.cor});

  Map<String, dynamic> toJson() => {'nome': nome, 'cor': cor.value};
  factory Categoria.fromJson(Map<String, dynamic> json) => 
      Categoria(nome: json['nome'], cor: Color(json['cor']));
}

class Compromisso {
  final String id;
  final String titulo;
  final String materia;
  final DateTime dataHora;
  final Categoria categoria;
  final String observacoes;
  final String repeticao;
  bool concluido;

  Compromisso({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.dataHora,
    required this.categoria,
    this.observacoes = '',
    this.repeticao = 'Nenhuma',
    this.concluido = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'materia': materia,
    'dataHora': dataHora.toIso8601String(),
    'categoria': categoria.toJson(),
    'observacoes': observacoes,
    'repeticao': repeticao,
    'concluido': concluido,
  };

  factory Compromisso.fromJson(Map<String, dynamic> json) => Compromisso(
    id: json['id'],
    titulo: json['titulo'],
    materia: json['materia'],
    dataHora: DateTime.parse(json['dataHora']),
    categoria: Categoria.fromJson(json['categoria']),
    observacoes: json['observacoes'] ?? '',
    repeticao: json['repeticao'] ?? 'Nenhuma',
    concluido: json['concluido'] ?? false,
  );
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _mesAtual = DateTime.now();
  DateTime _diaSelecionado = DateTime.now();
  String _filtroAtivo = 'Todos';
  List<Compromisso> _agenda = [];
  late Timer _timer;

  final List<Categoria> _categorias = [
    Categoria(nome: 'Challenge', cor: const Color(0xFFBB86FC)),
    Categoria(nome: 'Checkpoint', cor: Colors.amber),
    Categoria(nome: 'Global', cor: const Color(0xFF03DAC6)),
    Categoria(nome: 'Pessoal', cor: Colors.pinkAccent),
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // --- PERSISTÊNCIA ---

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('agenda_data');
    if (data != null) {
      final List decode = jsonDecode(data);
      setState(() {
        _agenda = decode.map((item) => Compromisso.fromJson(item)).toList();
      });
    }
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_agenda.map((e) => e.toJson()).toList());
    await prefs.setString('agenda_data', data);
  }

  // --- LÓGICA DE EXIBIÇÃO E REPETIÇÃO ---

  bool _deveExibirNoDia(Compromisso item, DateTime diaAlvo) {
    final dataInicio = DateTime(item.dataHora.year, item.dataHora.month, item.dataHora.day);
    final dataComparacao = DateTime(diaAlvo.year, diaAlvo.month, diaAlvo.day);

    if (dataComparacao.isAtSameMomentAs(dataInicio)) return true;
    if (dataComparacao.isBefore(dataInicio)) return false;

    switch (item.repeticao) {
      case 'Diária':
        return true;
      case 'Semanal':
        return dataInicio.weekday == dataComparacao.weekday;
      case 'Mensal':
        return dataInicio.day == dataComparacao.day;
      default:
        return false;
    }
  }

  // --- INTERFACE DE CADASTRO ---

  Future<void> _selecionarDataHora(BuildContext context, StateSetter setModalState) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _diaSelecionado,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_diaSelecionado),
      );
      if (hora != null) {
        setModalState(() {
          _diaSelecionado = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
        });
      }
    }
  }

  void _abrirGerenciadorCategorias() {
    final TextEditingController catController = TextEditingController();
    Color corSelecionada = Colors.redAccent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F33),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("GERENCIAR CATEGORIAS", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ..._categorias.map((c) => ListTile(
                leading: CircleAvatar(backgroundColor: c.cor, radius: 8),
                title: Text(c.nome, style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white24),
                  onPressed: () => setState(() => _categorias.remove(c)),
                ),
              )),
              TextField(controller: catController, style: const TextStyle(color: Colors.white), decoration: _inputStyle("Nova categoria")),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (catController.text.isNotEmpty) {
                    setState(() => _categorias.add(Categoria(nome: catController.text, cor: corSelecionada)));
                    Navigator.pop(context);
                  }
                },
                child: const Text("ADICIONAR"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _abrirFormularioCadastro() {
    final tController = TextEditingController();
    final mController = TextEditingController();
    final oController = TextEditingController();
    Categoria? catSel = _categorias.isNotEmpty ? _categorias.first : null;
    String repSel = 'Nenhuma';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F33),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("NOVA MISSÃO", style: TextStyle(color: Color(0xFFBB86FC), fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(controller: tController, style: const TextStyle(color: Colors.white), decoration: _inputStyle("Título (ex: Dentista)")),
                const SizedBox(height: 10),
                TextField(controller: mController, style: const TextStyle(color: Colors.white), decoration: _inputStyle("Matéria / Local")),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selecionarDataHora(context, setModalState),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                          child: Text(DateFormat('dd/MM - HH:mm').format(_diaSelecionado), style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: repSel,
                      dropdownColor: const Color(0xFF1C1F33),
                      items: ['Nenhuma', 'Diária', 'Semanal', 'Mensal'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (v) => setModalState(() => repSel = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  children: _categorias.map((cat) => ChoiceChip(
                    label: Text(cat.nome),
                    selected: catSel == cat,
                    onSelected: (s) => setModalState(() => catSel = cat),
                    selectedColor: cat.cor,
                  )).toList(),
                ),
                const SizedBox(height: 15),
                TextField(controller: oController, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: _inputStyle("Observações")),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03DAC6), minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    if (tController.text.isNotEmpty && catSel != null) {
                      setState(() {
                        _agenda.add(Compromisso(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          titulo: tController.text,
                          materia: mController.text,
                          dataHora: _diaSelecionado,
                          categoria: catSel!,
                          observacoes: oController.text,
                          repeticao: repSel,
                        ));
                      });
                      _salvarDados();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("SALVAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Colors.white24),
    filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  // --- COMPONENTES DA TELA ---

  @override
  Widget build(BuildContext context) {
    final filtrados = _agenda.where((e) => 
      _deveExibirNoDia(e, _diaSelecionado) && 
      (_filtroAtivo == 'Todos' || e.categoria.nome == _filtroAtivo)
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildCalendarioGrid(),
            const SizedBox(height: 30),
            _buildFiltros(),
            const SizedBox(height: 20),
            _buildLista(filtrados),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(DateFormat('MMMM yyyy', 'pt_BR').format(_mesAtual).toUpperCase(), 
             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFFBB86FC)), onPressed: _abrirFormularioCadastro),
            IconButton(icon: const Icon(Icons.flag_rounded, color: Colors.redAccent), onPressed: _abrirGerenciadorCategorias),
            IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => setState(() => _mesAtual = DateTime(_mesAtual.year, _mesAtual.month - 1))),
            IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => setState(() => _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + 1))),
          ],
        )
      ],
    );
  }

  Widget _buildCalendarioGrid() {
    final inicioMes = DateTime(_mesAtual.year, _mesAtual.month, 1);
    final fimMes = DateTime(_mesAtual.year, _mesAtual.month + 1, 0);
    final offset = inicioMes.weekday % 7;
    final dias = [
      ...List.generate(offset, (i) => null),
      ...List.generate(fimMes.day, (i) => DateTime(_mesAtual.year, _mesAtual.month, i + 1)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: dias.length,
      itemBuilder: (context, index) {
        final d = dias[index];
        if (d == null) return const SizedBox();
        bool isSel = d.day == _diaSelecionado.day && d.month == _diaSelecionado.month;
        bool temEvento = _agenda.any((e) => _deveExibirNoDia(e, d) && !e.concluido);

        return GestureDetector(
          onTap: () => setState(() => _diaSelecionado = d),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFFBB86FC) : Colors.transparent,
              shape: BoxShape.circle,
              border: temEvento && !isSel ? Border.all(color: Colors.redAccent, width: 1.5) : null,
            ),
            child: Center(child: Text(d.day.toString(), style: TextStyle(color: isSel ? Colors.black : Colors.white))),
          ),
        );
      },
    );
  }

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Todos', ..._categorias.map((c) => c.nome)].map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f, style: const TextStyle(fontSize: 12)),
            selected: _filtroAtivo == f,
            onSelected: (s) => setState(() => _filtroAtivo = f),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildLista(List<Compromisso> filtrados) {
    if (filtrados.isEmpty) return const Center(child: Text("Nada para hoje.", style: TextStyle(color: Colors.white24)));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final item = filtrados[index];
        return Dismissible(
          key: Key(item.id),
          onDismissed: (d) {
            setState(() => _agenda.remove(item));
            _salvarDados();
          },
          background: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Icon(Icons.delete, color: Colors.white)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: const Color(0xFF1C1F33), borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: Checkbox(
                value: item.concluido,
                onChanged: (v) {
                  setState(() => item.concluido = v!);
                  _salvarDados();
                }
              ),
              title: Text(item.titulo, style: TextStyle(color: Colors.white, decoration: item.concluido ? TextDecoration.lineThrough : null)),
              subtitle: Text("${DateFormat('HH:mm').format(item.dataHora)} - ${item.materia}", style: const TextStyle(color: Colors.white24, fontSize: 11)),
              children: [
                if (item.observacoes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(alignment: Alignment.centerLeft, child: Text(item.observacoes, style: const TextStyle(color: Colors.white70))),
                  ),
                if (item.repeticao != 'Nenhuma')
                  ListTile(title: Text("Repetição: ${item.repeticao}", style: const TextStyle(color: Colors.amber, fontSize: 12))),
              ],
            ),
          ),
        );
      },
    );
  }
}