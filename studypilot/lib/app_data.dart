import 'package:flutter/material.dart';

// Modelo Simples de Tarefa
class Tarefa {
  final String titulo;
  final DateTime prazo;
  final Color cor;
  bool concluida;
  Tarefa(this.titulo, this.prazo, this.cor, {this.concluida = false});
}

// Modelo de Pasta de Estudo
class PastaEstudo {
  final String nome;
  double progresso; // 0.0 a 1.0
  final Color cor;
  PastaEstudo(this.nome, this.progresso, this.cor);
}

class AppData extends ChangeNotifier {
  // Singleton para acessar de qualquer lugar
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // ADICIONE ESTE MÉTODO ABAIXO:
  void notificar() {
    notifyListeners();
  }

  // --- DADOS REAIS ---
  
  // Agenda
  List<Tarefa> tarefas = [
    Tarefa("Checkpoint 2 - Mobile", DateTime.now().add(const Duration(hours: 5)), Colors.redAccent),
    Tarefa("Global Solution", DateTime.now().add(const Duration(days: 12)), Colors.amber),
  ];

  // Estudos
  List<PastaEstudo> pastas = [
    PastaEstudo("Dev Cross-Platform", 0.72, const Color(0xFFBB86FC)),
    PastaEstudo("Engenharia de Software", 0.35, const Color(0xFF03DAC6)),
  ];

  // Finanças
  double saldoMensal = 1420.50;

  // --- MÉTODOS DE ATUALIZAÇÃO ---
  
  void adicionarTarefa(Tarefa t) {
    tarefas.add(t);
    tarefas.sort((a, b) => a.prazo.compareTo(b.prazo)); // Ordena por data
    notifyListeners();
  }

  void atualizarProgressoEstudo(int index, double novoProgresso) {
    pastas[index].progresso = novoProgresso;
    notifyListeners();
  }
}