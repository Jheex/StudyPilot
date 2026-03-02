import 'package:flutter/material.dart';
import 'app_data.dart'; // Importante: Garanta que o caminho do arquivo esteja correto

class FinancasScreen extends StatefulWidget {
  const FinancasScreen({super.key});

  @override
  State<FinancasScreen> createState() => _FinancasScreenState();
}

class _FinancasScreenState extends State<FinancasScreen> {
  final AppData appData = AppData(); // Instância do Singleton para acessar saldo e categorias
  bool saldoVisivel = true;

  // --- GERENCIADOR DE CATEGORIAS (CRUD) ---
  void _gerenciarCategorias() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F33),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("GERENCIAR CATEGORIAS",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView(
                      shrinkWrap: true,
                      children: appData.categoriasGastos.keys.map((cat) => ListTile(
                            leading: const Icon(Icons.label_important_outline,
                                color: Color(0xFFBB86FC)),
                            title: Text(cat),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () =>
                                      _editarCategoria(cat, setModalState),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: Colors.redAccent),
                                  onPressed: () {
                                    if (appData.categoriasGastos.length > 1) {
                                      setState(() => appData.removerCategoria(cat));
                                      setModalState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                          )).toList(),
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  ListTile(
                    leading: const Icon(Icons.add, color: Colors.greenAccent),
                    title: const Text("Adicionar Nova",
                        style: TextStyle(color: Colors.greenAccent)),
                    onTap: () => _adicionarCategoria(setModalState),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _adicionarCategoria(StateSetter setModalState) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F33),
        title: const Text("Nova Categoria"),
        content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => appData.adicionarCategoria(controller.text));
                setModalState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("CRIAR"),
          )
        ],
      ),
    );
  }

  void _editarCategoria(String nomeAntigo, StateSetter setModalState) {
    final TextEditingController controller =
        TextEditingController(text: nomeAntigo);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F33),
        title: const Text("Editar Categoria"),
        content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != nomeAntigo) {
                setState(() => appData.editarCategoria(nomeAntigo, controller.text));
                setModalState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("SALVAR"),
          )
        ],
      ),
    );
  }

  void _abrirFormulario(bool isEntrada) {
    final TextEditingController valorController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String categoriaSelecionada = appData.categoriasGastos.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F33),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isEntrada ? "Nova Entrada 💰" : "Nova Saída 💸",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                      controller: valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: "Valor (R\$)",
                          border: OutlineInputBorder(),
                          prefixText: "R\$ ")),
                  const SizedBox(height: 15),
                  TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                          labelText: "Descrição", border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  if (!isEntrada)
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1C1F33),
                      value: categoriaSelecionada,
                      items: appData.categoriasGastos.keys
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) =>
                          setModalState(() => categoriaSelecionada = val!),
                      decoration: const InputDecoration(
                          labelText: "Categoria", border: OutlineInputBorder()),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isEntrada ? Colors.greenAccent : Colors.redAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        double valor = double.tryParse(
                                valorController.text.replaceAll(',', '.')) ??
                            0.0;
                        setState(() {
                          if (isEntrada) {
                            appData.atualizarSaldo(valor);
                          } else {
                            appData.atualizarSaldo(-valor);
                            appData.adicionarGasto(categoriaSelecionada, valor);
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("CONFIRMAR",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
          const Text("SAÚDE FINANCEIRA",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                  letterSpacing: 2)),
          const SizedBox(height: 20),
          _buildSaldoCard(),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                  child: _actionButton("ENTRADA", Icons.add_circle_outline,
                      Colors.greenAccent, () => _abrirFormulario(true))),
              const SizedBox(width: 15),
              Expanded(
                  child: _actionButton("SAÍDA", Icons.remove_circle_outline,
                      Colors.redAccent, () => _abrirFormulario(false))),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _gerenciarCategorias,
              icon: const Icon(Icons.settings_suggest_outlined, size: 18),
              label: const Text("GERENCIAR CATEGORIAS",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFBB86FC),
                side: const BorderSide(color: Color(0xFFBB86FC), width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text("ANÁLISE DE GASTOS",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70)),
          const SizedBox(height: 20),
          ...appData.categoriasGastos.entries.map((e) {
            double totalGastos = appData.categoriasGastos.values
                .fold(0, (prev, element) => prev + element);
            double porcentagem = totalGastos > 0 ? (e.value / totalGastos) : 0.0;
            return _buildCategoryRow(e.key, e.value, porcentagem);
          }),
        ],
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: const Color(0xFF1C1F33),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Saldo Disponível",
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          IconButton(
              icon: Icon(
                  saldoVisivel
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white30),
              onPressed: () => setState(() => saldoVisivel = !saldoVisivel))
        ]),
        Text(
            saldoVisivel
                ? "R\$ ${appData.saldoTotal.toStringAsFixed(2)}"
                : "R\$ ••••••",
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
      ]),
    );
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withValues(alpha: 0.2))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12))
            ])));
  }

  Widget _buildCategoryRow(String label, double valor, double percent) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.white60)),
            Text("R\$ ${valor.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              color: const Color(0xFFBB86FC),
              minHeight: 4)
        ]));
  }
}