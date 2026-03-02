import 'package:flutter/material.dart';

// --- SEUS MODELOS (MANTIDOS) ---
class Categoria {
  String nome;
  Color cor;
  Categoria({required this.nome, required this.cor});
  Map<String, dynamic> toJson() => {'nome': nome, 'cor': cor.toARGB32()};
  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(nome: json['nome'], cor: Color(json['cor']));
}

class Compromisso {
  final String id, titulo, materia;
  final DateTime dataHora;
  final Categoria categoria;
  final String observacoes, repeticao;
  bool concluido;

  Compromisso({required this.id, required this.titulo, required this.materia, required this.dataHora, required this.categoria, this.observacoes = '', this.repeticao = 'Nenhuma', this.concluido = false});
  Map<String, dynamic> toJson() => {'id': id, 'titulo': titulo, 'materia': materia, 'dataHora': dataHora.toIso8601String(), 'categoria': categoria.toJson(), 'observacoes': observacoes, 'repeticao': repeticao, 'concluido': concluido};
  factory Compromisso.fromJson(Map<String, dynamic> json) => Compromisso(id: json['id'], titulo: json['titulo'], materia: json['materia'], dataHora: DateTime.parse(json['dataHora']), categoria: Categoria.fromJson(json['categoria']), observacoes: json['observacoes'] ?? '', repeticao: json['repeticao'] ?? 'Nenhuma', concluido: json['concluido'] ?? false);
}

class PastaEstudo {
  final String nome;
  double progresso;
  final Color cor;
  PastaEstudo(this.nome, this.progresso, this.cor);
}

// --- CLASSE APPDATA ATUALIZADA ---
class AppData extends ChangeNotifier {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // Agenda e Estudos
  List<Compromisso> tarefas = [];
  List<PastaEstudo> pastas = [
    PastaEstudo("Dev Cross-Platform", 0.72, const Color(0xFFBB86FC)),
    PastaEstudo("Engenharia de Software", 0.35, const Color(0xFF03DAC6)),
  ];

  // ==========================================
  // FINANÇAS (O QUE ESTAVA FALTANDO)
  // ==========================================
  double saldoTotal = 1420.50; // Valor inicial
  
  Map<String, double> categoriasGastos = {
    "Educação": 0.0,
    "Lazer": 0.0,
    "Assinaturas": 0.0,
    "Alimentação": 0.0,
  };

  // Getter para o seu Dashboard (Main) que usa 'saldoMensal'
  double get saldoMensal => saldoTotal;

  void atualizarSaldo(double valor) {
    saldoTotal += valor;
    notifyListeners();
  }

  void adicionarGasto(String categoria, double valor) {
    if (categoriasGastos.containsKey(categoria)) {
      categoriasGastos[categoria] = (categoriasGastos[categoria] ?? 0.0) + valor;
    }
    notifyListeners();
  }

  void adicionarCategoria(String nome) {
    if (!categoriasGastos.containsKey(nome)) {
      categoriasGastos[nome] = 0.0;
      notifyListeners();
    }
  }

  void removerCategoria(String nome) {
    categoriasGastos.remove(nome);
    notifyListeners();
  }

  void editarCategoria(String nomeAntigo, String nomeNovo) {
    if (categoriasGastos.containsKey(nomeAntigo)) {
      double valor = categoriasGastos.remove(nomeAntigo) ?? 0.0;
      categoriasGastos[nomeNovo] = valor;
      notifyListeners();
    }
  }

  // Agenda e Estudos Methods
  void atualizarAgenda(List<Compromisso> novaLista) {
    tarefas = List.from(novaLista);
    tarefas.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    notifyListeners();
  }
}