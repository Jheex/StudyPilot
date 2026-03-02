import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. MODELOS DE DADOS (ESTUDOS)
// ==========================================

class EstudoLog {
  String texto;
  final String data;
  final int xp;
  final DateTime timestamp;

  EstudoLog({required this.texto, required this.data, this.xp = 100, DateTime? timestamp}) 
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {'texto': texto, 'data': data, 'xp': xp, 'timestamp': timestamp.toIso8601String()};
  factory EstudoLog.fromJson(Map<String, dynamic> json) => EstudoLog(
    texto: json['texto'], 
    data: json['data'], 
    xp: json['xp'] ?? 100,
    timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now()
  );
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

  // CORRIGIDO: .value -> .toARGB32()
  Map<String, dynamic> toJson() => {'nome': nome, 'cor': cor.toARGB32(), 'materias': materias.map((m) => m.toJson()).toList()};
  
  factory PastaEstudo.fromJson(Map<String, dynamic> json) => PastaEstudo(
    nome: json['nome'],
    cor: Color(json['cor']), // O construtor Color ainda aceita o int retornado pelo JSON
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

// ==========================================
// 2. MODELOS DE DADOS (AGENDA)
// ==========================================

class Categoria {
  String nome;
  Color cor;
  Categoria({required this.nome, required this.cor});
  
  // CORRIGIDO: .value -> .toARGB32()
  Map<String, dynamic> toJson() => {'nome': nome, 'cor': cor.toARGB32()};
  
  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    nome: json['nome'], 
    cor: Color(json['cor'] as int)
  );
}

class Compromisso {
  final String id, titulo, materia;
  final DateTime dataHora;
  final Categoria categoria;
  final String observacoes, repeticao;
  bool concluido;

  Compromisso({required this.id, required this.titulo, required this.materia, required this.dataHora, required this.categoria, this.observacoes = '', this.repeticao = 'Nenhuma', this.concluido = false});
  Map<String, dynamic> toJson() => {'id': id, 'titulo': titulo, 'materia': materia, 'dataHora': dataHora.toIso8601String(), 'categoria': categoria.toJson(), 'observacoes': observacoes, 'repeticao': repeticao, 'concluido': concluido};
  factory Compromisso.fromJson(Map<String, dynamic> json) => Compromisso(
    id: json['id'], 
    titulo: json['titulo'], 
    materia: json['materia'], 
    dataHora: DateTime.parse(json['dataHora']), 
    categoria: Categoria.fromJson(json['categoria']), 
    observacoes: json['observacoes'] ?? '', 
    repeticao: json['repeticao'] ?? 'Nenhuma', 
    concluido: json['concluido'] ?? false
  );
}

// ==========================================
// 3. GERENCIADOR DE ESTADO (APPDATA)
// ==========================================

class AppData extends ChangeNotifier {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  List<PastaEstudo> pastas = [];
  List<Compromisso> tarefas = [];
  double saldoTotal = 0.0;
  Map<String, double> categoriasGastos = {
    "Educação": 0.0,
    "Lazer": 0.0,
    "Assinaturas": 0.0,
    "Alimentação": 0.0,
  };

  int get totalXP => pastas.fold(0, (sum, p) => sum + p.totalXP);

  // --- PERSISTÊNCIA ---
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? studyData = prefs.getString('study_pilot_v3');
    if (studyData != null) {
      Iterable l = jsonDecode(studyData);
      pastas = l.map((model) => PastaEstudo.fromJson(model)).toList();
    }

    final String? agendaData = prefs.getString('agenda_data');
    if (agendaData != null) {
      Iterable l = jsonDecode(agendaData);
      tarefas = l.map((model) => Compromisso.fromJson(model)).toList();
    }

    saldoTotal = prefs.getDouble('saldo_total') ?? 0.0;
    final String? gastosData = prefs.getString('categorias_gastos');
    if (gastosData != null) {
      Map<String, dynamic> map = jsonDecode(gastosData);
      categoriasGastos = map.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('study_pilot_v3', jsonEncode(pastas));
    await prefs.setString('agenda_data', jsonEncode(tarefas));
    await prefs.setDouble('saldo_total', saldoTotal);
    await prefs.setString('categorias_gastos', jsonEncode(categoriasGastos));
    notifyListeners();
  }

  // MÉTODOS SIMPLIFICADOS PARA EXEMPLO
  void adicionarPasta(String nome, Color cor) {
    pastas.add(PastaEstudo(nome: nome, cor: cor, materias: []));
    _save();
  }

  void editarPasta(PastaEstudo pasta, String novoNome, Color novaCor) {
    pasta.nome = novoNome;
    pasta.cor = novaCor;
    _save();
  }

  void removerPasta(PastaEstudo pasta) {
    pastas.remove(pasta);
    _save();
  }

  void adicionarMateria(PastaEstudo pasta, String nome) {
    pasta.materias.add(Materia(id: DateTime.now().toString(), nome: nome, logs: []));
    _save();
  }

  void editarMateria(Materia materia, String novoNome) {
    materia.nome = novoNome;
    _save();
  }

  void removerMateria(PastaEstudo pasta, Materia materia) {
    pasta.materias.remove(materia);
    _save();
  }

  void adicionarLog(Materia materia, String texto) {
    materia.logs.insert(0, EstudoLog(
      texto: texto, 
      data: "${DateTime.now().day}/${DateTime.now().month}",
    ));
    _save();
  }

  void editarLog(EstudoLog log, String novoTexto) {
    log.texto = novoTexto;
    _save();
  }

  void removerLog(Materia materia, EstudoLog log) {
    materia.logs.remove(log);
    _save();
  }

  void atualizarSaldo(double valor) {
    saldoTotal += valor;
    _save();
  }

  void adicionarGasto(String categoria, double valor) {
    if (categoriasGastos.containsKey(categoria)) {
      categoriasGastos[categoria] = (categoriasGastos[categoria] ?? 0.0) + valor;
      _save();
    }
  }

  void adicionarCategoriaFinancas(String nome) {
    if (!categoriasGastos.containsKey(nome)) {
      categoriasGastos[nome] = 0.0;
      _save();
    }
  }

  void removerCategoriaFinancas(String nome) {
    categoriasGastos.remove(nome);
    _save();
  }

  void editarCategoriaFinancas(String nomeAntigo, String nomeNovo) {
    if (categoriasGastos.containsKey(nomeAntigo)) {
      double valor = categoriasGastos.remove(nomeAntigo)!;
      categoriasGastos[nomeNovo] = valor;
      _save();
    }
  }

  void adicionarTarefa(Compromisso tarefa) {
    tarefas.add(tarefa);
    tarefas.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    _save();
  }

  void alternarTarefa(Compromisso tarefa) {
    tarefa.concluido = !tarefa.concluido;
    _save();
  }

  void removerTarefa(Compromisso tarefa) {
    tarefas.remove(tarefa);
    _save();
  }

  void atualizarAgenda(List<Compromisso> novaLista) {
    tarefas = List.from(novaLista);
    tarefas.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    _save();
  }
}