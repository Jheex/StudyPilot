import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transacao {
  final String descricao;
  final double valor;
  final String categoria;
  final DateTime data;
  final bool isEntrada;

  Transacao({
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.data,
    required this.isEntrada,
  });
}

class FinancasScreen extends StatefulWidget {
  const FinancasScreen({super.key});

  @override
  State<FinancasScreen> createState() => _FinancasScreenState();
}

class _FinancasScreenState extends State<FinancasScreen> {
  double saldoTotal = 0.0;
  bool saldoVisivel = true;
  final List<Transacao> _historico = [];
  
  Map<String, double> categoriasGastos = {
    "Educação": 0.0, "Lazer": 0.0, "Assinaturas": 0.0, "Alimentação": 0.0,
  };

  void _abrirFormulario(bool isEntrada) {
    final TextEditingController valorController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String categoriaSelecionada = categoriasGastos.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F33),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isEntrada ? "Nova Entrada 💰" : "Nova Saída 💸", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(controller: valorController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: "Valor (R\$)", border: OutlineInputBorder(), prefixText: "R\$ ")),
                  const SizedBox(height: 15),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição/Motivo", border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  if (!isEntrada)
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1C1F33),
                      value: categoriaSelecionada,
                      items: categoriasGastos.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setModalState(() => categoriaSelecionada = val!),
                      decoration: const InputDecoration(labelText: "Categoria", border: OutlineInputBorder()),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: isEntrada ? Colors.greenAccent : Colors.redAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        double valor = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0;
                        setState(() {
                          if (isEntrada) { 
                            saldoTotal += valor; 
                          } else {
                            saldoTotal -= valor;
                            categoriasGastos[categoriaSelecionada] = (categoriasGastos[categoriaSelecionada] ?? 0) + valor;
                          }
                          _historico.insert(0, Transacao(
                            descricao: descController.text.isEmpty ? (isEntrada ? "Entrada" : "Saída") : descController.text,
                            valor: valor,
                            categoria: isEntrada ? "Depósito" : categoriaSelecionada,
                            data: DateTime.now(),
                            isEntrada: isEntrada,
                          ));
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("CONFIRMAR", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SAÚDE FINANCEIRA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 2)),
          const SizedBox(height: 20),
          _buildSaldoCard(),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _actionButton("ENTRADA", Icons.add_circle_outline, Colors.greenAccent, () => _abrirFormulario(true))),
              const SizedBox(width: 15),
              Expanded(child: _actionButton("SAÍDA", Icons.remove_circle_outline, Colors.redAccent, () => _abrirFormulario(false))),
            ],
          ),
          const SizedBox(height: 15),
          _buildManageButton(),
          const SizedBox(height: 40),
          const Text("LOG DE MOVIMENTAÇÕES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 20),
          _historico.isEmpty 
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Nenhuma movimentação ainda.", style: TextStyle(color: Colors.white24, fontSize: 12))))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _historico.length,
                itemBuilder: (context, index) => _buildLogTile(_historico[index]),
              ),
          const SizedBox(height: 40),
          const Text("ANÁLISE POR CATEGORIA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 20),
          ...categoriasGastos.entries.map((e) {
            double totalGastos = categoriasGastos.values.fold(0, (prev, element) => prev + element);
            return _buildCategoryRow(e.key, e.value, totalGastos > 0 ? (e.value / totalGastos) : 0.0);
          }),
        ],
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F33), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Saldo Total", style: TextStyle(color: Colors.white38, fontSize: 12)),
          // O OLHINHO VOLTOU AQUI:
          IconButton(
            icon: Icon(saldoVisivel ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white30, size: 20),
            onPressed: () => setState(() => saldoVisivel = !saldoVisivel),
          )
        ]),
        Text(
          saldoVisivel ? "R\$ ${saldoTotal.toStringAsFixed(2)}" : "R\$ ••••••", 
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)
        ),
      ]),
    );
  }

  Widget _buildLogTile(Transacao item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F33).withAlpha(128),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(item.isEntrada ? Icons.arrow_upward : Icons.arrow_downward, 
               color: item.isEntrada ? Colors.greenAccent : Colors.redAccent, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${item.categoria} • ${DateFormat('dd/MM HH:mm').format(item.data)}", 
                     style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          // CORES CORRIGIDAS AQUI:
          Text(
            "${item.isEntrada ? '+' : '-'} R\$ ${item.valor.toStringAsFixed(2)}", 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: item.isEntrada ? Colors.greenAccent : Colors.redAccent,
            )
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares de UI
  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(15)), child: Center(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)))));
  }

  Widget _buildManageButton() {
    return SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _gerenciarCategorias, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("GERENCIAR CATEGORIAS", style: TextStyle(fontSize: 10, color: Colors.white60))));
  }

  Widget _buildCategoryRow(String label, double valor, double percent) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)), Text("R\$ ${valor.toStringAsFixed(2)}")]), const SizedBox(height: 5), LinearProgressIndicator(value: percent, backgroundColor: Colors.white10, color: const Color(0xFFBB86FC), minHeight: 2)]));
  }

  // Lógica de gestão simplificada para o exemplo
  void _gerenciarCategorias() {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1C1F33), builder: (context) => const Center(child: Text("Gerenciador de Categorias")));
  }
}