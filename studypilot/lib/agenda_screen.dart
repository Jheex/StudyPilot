import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Modelo de Dados
class Compromisso {
  final String id;
  final String titulo;
  final String materia;
  final DateTime prazo;

  Compromisso({
    required this.id, 
    required this.titulo, 
    required this.materia, 
    required this.prazo
  });

  // Lógica de Cores baseada na proximidade
  Color get corUrgencia {
    final hoje = DateTime.now();
    final diferenca = prazo.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
    
    if (diferenca < 0) return Colors.grey;          // Vencido
    if (diferenca <= 1) return const Color(0xFFCF6679); // Crítico (Hoje ou Amanhã)
    if (diferenca <= 3) return Colors.amber;          // Atenção
    return const Color(0xFF03DAC6);                 // Tranquilo
  }
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _mesAtual = DateTime.now();
  DateTime _diaSelecionado = DateTime.now();

  // Lista mockada (Exemplos)
  final List<Compromisso> _agenda = [
    Compromisso(
      id: '1', 
      titulo: "Entrega de Challenge", 
      materia: "FIAP - Fase 3", 
      prazo: DateTime.now().add(const Duration(days: 1))
    ),
    Compromisso(
      id: '2', 
      titulo: "Checkpoint Python", 
      materia: "FIAP - Global", 
      prazo: DateTime.now().add(const Duration(days: 3))
    ),
    Compromisso(
      id: '3', 
      titulo: "Sprint Java", 
      materia: "Software Architecture", 
      prazo: DateTime.now().add(const Duration(days: 7))
    ),
  ];

  // Gerador de dias do mês para o Grid
  List<DateTime?> _gerarDiasMes() {
    final inicioMes = DateTime(_mesAtual.year, _mesAtual.month, 1);
    final fimMes = DateTime(_mesAtual.year, _mesAtual.month + 1, 0);
    final diaDaSemanaInicio = inicioMes.weekday % 7; 

    List<DateTime?> dias = List.generate(diaDaSemanaInicio, (index) => null);
    for (int i = 1; i <= fimMes.day; i++) {
      dias.add(DateTime(_mesAtual.year, _mesAtual.month, i));
    }
    return dias;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCalendario(),
          const SizedBox(height: 20),
          _buildGradeCalendario(),
          const SizedBox(height: 35),
          const Text(
            "PRÓXIMOS PRAZOS",
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFFCF6679), 
              letterSpacing: 2
            ),
          ),
          const SizedBox(height: 15),
          _buildListaPrazos(),
        ],
      ),
    );
  }

  Widget _buildHeaderCalendario() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy', 'pt_BR').format(_mesAtual).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _mesAtual = DateTime(_mesAtual.year, _mesAtual.month - 1)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + 1)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradeCalendario() {
    final dias = _gerarDiasMes();
    const diasSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: diasSemana.map((d) => Text(d, style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold))).toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: dias.length,
          itemBuilder: (context, index) {
            final data = dias[index];
            if (data == null) return const SizedBox();

            bool isHoje = data.day == DateTime.now().day && data.month == DateTime.now().month && data.year == DateTime.now().year;
            bool isSelecionado = data.day == _diaSelecionado.day && data.month == _diaSelecionado.month && data.year == _diaSelecionado.year;
            
            // Verifica se tem algum compromisso neste dia
            bool temEvento = _agenda.any((e) => e.prazo.day == data.day && e.prazo.month == data.month && e.prazo.year == data.year);

            return GestureDetector(
              onTap: () => setState(() => _diaSelecionado = data),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelecionado ? const Color(0xFFBB86FC) : (isHoje ? Colors.white.withOpacity(0.1) : Colors.transparent),
                  shape: BoxShape.circle,
                  border: temEvento && !isSelecionado ? Border.all(color: const Color(0xFFCF6679), width: 1.5) : null,
                ),
                child: Center(
                  child: Text(
                    data.day.toString(),
                    style: TextStyle(
                      color: isSelecionado ? Colors.black : Colors.white,
                      fontWeight: isSelecionado || isHoje ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildListaPrazos() {
    // Filtra os prazos que pertencem ao mês que o usuário está visualizando
    final itensDoMes = _agenda.where((c) => c.prazo.month == _mesAtual.month && c.prazo.year == _mesAtual.year).toList();

    if (itensDoMes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("Nenhum compromisso para este mês.", style: TextStyle(color: Colors.white24, fontSize: 12)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itensDoMes.length,
      itemBuilder: (context, index) {
        final item = itensDoMes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F33),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(width: 4, height: 40, color: item.corUrgencia),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(item.materia, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd/MM').format(item.prazo),
                    style: TextStyle(color: item.corUrgencia, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text("PRAZO", style: TextStyle(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}