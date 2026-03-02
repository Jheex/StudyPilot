import 'package:flutter/material.dart';
import 'app_data.dart'; // Importante para acessar a mesma lista

class ItemCompra {
  String nome;
  bool comprado;
  double preco;
  String categoria;

  ItemCompra({
    required this.nome,
    this.comprado = false,
    this.preco = 0.0,
    this.categoria = "Geral",
  });
}

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  // Instanciando o AppData para acessar as categorias dinâmicas
  final AppData appData = AppData(); 
  
  final List<ItemCompra> _lista = [];
  final TextEditingController _itemController = TextEditingController();

  static const Color kBackgroundColor = Color(0xFF121421);
  static const Color kCardColor = Color(0xFF1C1F33);
  static const Color kAccentColor = Color(0xFFBB86FC);
  static const Color kSecondaryColor = Color(0xFF03DAC6);
  static const Color kErrorColor = Color(0xFFCF6679);

  // --- FLUXO: ESCREVE -> CLICA + -> ESCOLHE CATEGORIA ---
  void _prepararAdicao() {
    if (_itemController.text.isEmpty) return;
    
    String nomeProduto = _itemController.text;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kCardColor,
          title: const Text("Vincular Categoria", 
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Escolha uma categoria das suas Finanças:", 
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 15),
                // USANDO A LISTA DINÂMICA DO APPDATA
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: appData.categoriasGastos.keys.map((cat) {
                      return ListTile(
                        dense: true,
                        title: Text(cat, style: const TextStyle(color: Colors.white)),
                        leading: const Icon(Icons.tag_rounded, color: kAccentColor, size: 18),
                        onTap: () {
                          setState(() {
                            _lista.add(ItemCompra(nome: nomeProduto, categoria: cat));
                            _itemController.clear();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const Divider(color: Colors.white10),
                // Botão para criar nova categoria ali na hora se não existir
                ListTile(
                  dense: true,
                  title: const Text("Nova Categoria...", style: TextStyle(color: kSecondaryColor)),
                  leading: const Icon(Icons.add, color: kSecondaryColor, size: 18),
                  onTap: () {
                    Navigator.pop(context);
                    _criarNovaCategoriaDireto(nomeProduto);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Permite criar a categoria em Compras e ela aparecerá em Finanças
  void _criarNovaCategoriaDireto(String nomeProduto) {
    final TextEditingController catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text("Nova Categoria"),
        content: TextField(
          controller: catController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Nome da categoria", hintStyle: TextStyle(color: Colors.white24)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("VOLTAR")),
          ElevatedButton(
            onPressed: () {
              if (catController.text.isNotEmpty) {
                setState(() {
                  appData.adicionarCategoriaFinancas(catController.text);
                  _lista.add(ItemCompra(nome: nomeProduto, categoria: catController.text));
                  _itemController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("CRIAR E VINCULAR"),
          )
        ],
      ),
    );
  }

  void _removerItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text("Excluir?", style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NÃO")),
          TextButton(
            onPressed: () {
              setState(() => _lista.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("SIM", style: TextStyle(color: kErrorColor)),
          ),
        ],
      ),
    );
  }

  double get _totalCarrinho => _lista.where((i) => i.comprado).fold(0, (sum, i) => sum + i.preco);

  void _editarPreco(int index) {
    TextEditingController precoController = TextEditingController(
      text: _lista[index].preco > 0 ? _lista[index].preco.toString() : "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text("Valor: ${_lista[index].nome}"),
        content: TextField(
          controller: precoController,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(prefixText: "R\$ "),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
            onPressed: () {
              setState(() {
                _lista[index].preco = double.tryParse(precoController.text.replaceFirst(',', '.')) ?? 0.0;
                if (_lista[index].preco > 0) _lista[index].comprado = true;
              });
              Navigator.pop(context);
            },
            child: const Text("SALVAR", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBackgroundColor,
      child: Column(
        children: [
          // Cabeçalho
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("LISTA DE COMPRAS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1.2)),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: kErrorColor, size: 20),
                  onPressed: () => setState(() => _lista.removeWhere((item) => item.comprado)),
                ),
              ],
            ),
          ),

          // Input Principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "O que vamos comprar?",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _prepararAdicao(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _prepararAdicao,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: kAccentColor, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add_rounded, color: Colors.black, size: 20),
                  ),
                )
              ],
            ),
          ),

          // Listagem
          Expanded(
            child: _lista.isEmpty
                ? const Center(child: Text("Sua lista está vazia", style: TextStyle(color: Colors.white24)))
                : ListView.builder(
                    itemCount: _lista.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final item = _lista[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: kCardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: item.comprado ? kSecondaryColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03)),
                        ),
                        child: ListTile(
                          onTap: () => _editarPreco(index),
                          leading: Checkbox(
                            value: item.comprado,
                            activeColor: kSecondaryColor,
                            onChanged: (val) {
                              setState(() => item.comprado = val!);
                              if (val! && item.preco == 0) _editarPreco(index);
                            },
                          ),
                          title: Text(item.nome, style: TextStyle(color: item.comprado ? Colors.white38 : Colors.white, decoration: item.comprado ? TextDecoration.lineThrough : null)),
                          subtitle: Text("${item.categoria} • R\$ ${item.preco.toStringAsFixed(2)}", style: TextStyle(color: item.preco > 0 ? kSecondaryColor : Colors.white24, fontSize: 11)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.white24), onPressed: () => _editarPreco(index)),
                              IconButton(icon: Icon(Icons.delete_outline_rounded, color: kErrorColor.withValues(alpha: 0.5)), onPressed: () => _removerItem(index)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Botão Finalizar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: kCardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL", style: TextStyle(color: Colors.white38, fontSize: 10)),
                    Text("R\$ ${_totalCarrinho.toStringAsFixed(2)}", style: const TextStyle(color: kSecondaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor, foregroundColor: Colors.black),
                    onPressed: _totalCarrinho > 0 ? () {
                      // Lógica de abatimento aqui
                    } : null,
                    child: const Text("FINALIZAR E DEBITAR SALDO"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}