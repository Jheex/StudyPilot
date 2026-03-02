import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_data.dart'; // ✅ Certifique-se que o arquivo app_data.dart existe

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
  List<Categoria> _categorias = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // --- PERSISTÊNCIA ---

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carregar Categorias Personalizadas
    final String? catData = prefs.getString('agenda_categorias');
    if (catData != null) {
      final List decodeCat = jsonDecode(catData);
      _categorias = decodeCat.map((item) => Categoria.fromJson(item)).toList();
    } else {
      // Categorias Iniciais se estiver vazio
      _categorias = [
        Categoria(nome: 'Todos', cor: Colors.grey),
      ];
    }

    // Carregar Agenda
    final String? data = prefs.getString('agenda_data');
    if (data != null) {
      final List decode = jsonDecode(data);
      setState(() {
        _agenda = decode.map((item) => Compromisso.fromJson(item)).toList();
      });
      AppData().atualizarAgenda(_agenda);
    }
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Salvar Agenda
    final String data = jsonEncode(_agenda.map((e) => e.toJson()).toList());
    await prefs.setString('agenda_data', data);
    
    // Salvar Categorias
    final String catData = jsonEncode(_categorias.map((e) => e.toJson()).toList());
    await prefs.setString('agenda_categorias', catData);

    AppData().atualizarAgenda(_agenda);
  }

  // --- LÓGICA DE EXIBIÇÃO ---

  bool _deveExibirNoDia(Compromisso item, DateTime diaAlvo) {
    final dataInicio = DateTime(item.dataHora.year, item.dataHora.month, item.dataHora.day);
    final dataComparacao = DateTime(diaAlvo.year, diaAlvo.month, diaAlvo.day);

    if (dataComparacao.isAtSameMomentAs(dataInicio)) return true;
    if (dataComparacao.isBefore(dataInicio)) return false;

    // Lógica para repetição por intervalo de dias (Ex: "17 Dias")
    if (item.repeticao.contains('Dias')) {
      int intervalo = int.tryParse(item.repeticao.split(' ')[0]) ?? 0;
      if (intervalo <= 0) return false;
      final diferencaEmDias = dataComparacao.difference(dataInicio).inDays;
      return diferencaEmDias % intervalo == 0;
    }

    switch (item.repeticao) {
      case 'Diária':
        return true;
      case 'Semanal':
        return dataInicio.weekday == dataComparacao.weekday;
      case 'Mensal':
        return dataInicio.day == dataComparacao.day;
      case 'Anual':
        return dataInicio.day == dataComparacao.day && dataInicio.month == dataComparacao.month;
      default:
        return false;
    }
  }

  // --- INTERFACE ---

  Future<void> _selecionarDataHora(BuildContext context, StateSetter setModalState) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _diaSelecionado,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      if (!context.mounted) return;
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
    
    // Lista de cores para as bolinhas
    final List<Color> paletaCores = [
      Colors.redAccent, Colors.orangeAccent, Colors.yellowAccent,
      Colors.greenAccent, Colors.blueAccent, Colors.purpleAccent,
      Colors.pinkAccent, const Color(0xFF03DAC6), const Color(0xFFBB86FC)
    ];

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
              
              // Lista de categorias existentes
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView(
                  shrinkWrap: true,
                  children: _categorias.map((c) => ListTile(
                    leading: CircleAvatar(backgroundColor: c.cor, radius: 6),
                    title: Text(c.nome, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white24),
                      onPressed: () {
                        setState(() => _categorias.remove(c));
                        setModalState(() {});
                        _salvarDados();
                      },
                    ),
                  )).toList(),
                ),
              ),
              
              const Divider(color: Colors.white10, height: 30),
              
              // Seletor de Cores (Bolinhas)
              const Text("Escolha uma cor:", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: paletaCores.map((cor) => GestureDetector(
                  onTap: () => setModalState(() => corSelecionada = cor),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: corSelecionada == cor ? Colors.white : Colors.transparent,
                        width: 2
                      ),
                    ),
                    child: CircleAvatar(backgroundColor: cor, radius: 12),
                  ),
                )).toList(),
              ),
              
              const SizedBox(height: 15),
              TextField(
                controller: catController, 
                style: const TextStyle(color: Colors.white), 
                decoration: _inputStyle("Nome da nova categoria")
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corSelecionada,
                  minimumSize: const Size(double.infinity, 45)
                ),
                onPressed: () {
                  if (catController.text.isNotEmpty) {
                    setState(() {
                      _categorias.add(Categoria(nome: catController.text, cor: corSelecionada));
                    });
                    _salvarDados();
                    Navigator.pop(context);
                  }
                },
                child: const Text("ADICIONAR CATEGORIA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
    final intervalController = TextEditingController(text: '1');
    
    // ✅ Começa nulo para forçar a escolha da categoria
    Categoria? catSel; 

    String repSel = 'Nenhuma';
    bool mostrarCampoIntervalo = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1F33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
            left: 20, 
            right: 20, 
            top: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NOVA MISSÃO", 
                  style: TextStyle(color: Color(0xFFBB86FC), fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 15),
                
                TextField(
                  controller: tController, 
                  style: const TextStyle(color: Colors.white), 
                  decoration: _inputStyle("Título")
                ),
                const SizedBox(height: 10),
                
                TextField(
                  controller: mController, 
                  style: const TextStyle(color: Colors.white), 
                  decoration: _inputStyle("Local / Descrição")
                ),
                const SizedBox(height: 15),
                
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selecionarDataHora(context, setModalState),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05), 
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy - HH:mm').format(_diaSelecionado), 
                            style: const TextStyle(color: Colors.white)
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: repSel,
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: const Color(0xFF1C1F33),
                      items: ['Nenhuma', 'Diária', 'Semanal', 'Mensal', 'Anual', 'Personalizado']
                          .map((s) => DropdownMenuItem(
                            value: s, 
                            child: Text(s, style: const TextStyle(color: Colors.white))
                          )).toList(),
                      onChanged: (v) {
                        setModalState(() {
                          repSel = v!;
                          mostrarCampoIntervalo = (v == 'Personalizado');
                        });
                      },
                    ),
                  ],
                ),
                
                if (mostrarCampoIntervalo) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Repetir a cada: ", style: TextStyle(color: Colors.white70)),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: intervalController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Text(" dias", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
                
                const SizedBox(height: 15),
                const Text(
                  "CATEGORIA", 
                  style: TextStyle(color: Colors.white54, fontSize: 12)
                ),
                const SizedBox(height: 8),

                // ✅ DROPDOWN DE CATEGORIAS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Categoria>(
                      value: catSel,
                      borderRadius: BorderRadius.circular(15),
                      hint: const Text(
                        "Selecione uma categoria", 
                        style: TextStyle(color: Colors.white38, fontSize: 14)
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1C1F33),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFBB86FC)),
                      items: [
                        // Opção para adicionar nova
                        DropdownMenuItem<Categoria>(
                          value: null,
                          child: Row(
                            children: const [
                              Icon(Icons.add_circle_outline, color: Color(0xFF03DAC6), size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Adicionar Nova...", 
                                style: TextStyle(color: Color(0xFF03DAC6), fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),
                        // Listagem das categorias existentes
                        ..._categorias.where((c) => c.nome != 'Todos').map((cat) => DropdownMenuItem<Categoria>(
                          value: cat,
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: cat.cor, radius: 6),
                              const SizedBox(width: 12),
                              Text(cat.nome, style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (Categoria? selecionada) {
                        if (selecionada == null) {
                          // Abre o gerenciador sem fechar o form principal se possível, 
                          // ou fecha e abre o gerenciador. Aqui mantemos sua lógica de fechar.
                          Navigator.pop(context); 
                          _abrirGerenciadorCategorias(); 
                        } else {
                          setModalState(() => catSel = selecionada);
                        }
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                TextField(
                  controller: oController, 
                  maxLines: 2, 
                  style: const TextStyle(color: Colors.white), 
                  decoration: _inputStyle("Observações")
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03DAC6), 
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    // Validação: Título e Categoria são obrigatórios
                    if (tController.text.isEmpty || catSel == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Preencha o título e escolha uma categoria!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    String repeticaoFinal = repSel;
                    if (repSel == 'Personalizado') {
                      repeticaoFinal = "${intervalController.text} Dias";
                    }

                    setState(() {
                      _agenda.add(Compromisso(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        titulo: tController.text,
                        materia: mController.text,
                        dataHora: _diaSelecionado,
                        categoria: catSel!, 
                        observacoes: oController.text,
                        repeticao: repeticaoFinal,
                      ));
                    });
                    
                    _salvarDados();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "SALVAR MISSÃO", 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                  ),
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
        bool isSel = d.day == _diaSelecionado.day && d.month == _diaSelecionado.month && d.year == _diaSelecionado.year;
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
    // Criamos uma lista de categorias que inclui uma categoria "virtual" para o 'Todos'
    final categoriasParaFiltro = [
      Categoria(nome: 'Todos', cor: const Color(0xFFBB86FC)), // Cor de destaque do seu app
      ..._categorias
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoriasParaFiltro.map((cat) {
          final bool isSelected = _filtroAtivo == cat.nome;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat.nome, 
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                )
              ),
              selected: isSelected,
              onSelected: (s) => setState(() => _filtroAtivo = cat.nome),
              // ✅ A MÁGICA ESTÁ AQUI: Usando a cor da categoria quando selecionado
              selectedColor: cat.cor,
              backgroundColor: const Color(0xFF1C1F33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              checkmarkColor: Colors.black,
              // Remove a sombra/borda cinza padrão
              side: BorderSide(
                color: isSelected ? cat.cor : Colors.white10,
                width: 1
              ),
            ),
          );
        }).toList(),
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
          direction: DismissDirection.endToStart, // Desliza da direita para a esquerda
          onDismissed: (d) {
            setState(() => _agenda.remove(item));
            _salvarDados();
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F33), 
              borderRadius: BorderRadius.circular(15),
              // ✅ BARRA LATERAL COM A COR DA CATEGORIA
              border: Border(left: BorderSide(color: item.categoria.cor, width: 6)),
            ),
            child: Theme(
              // Remove as linhas que o ExpansionTile cria por padrão
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Checkbox(
                  value: item.concluido,
                  // ✅ CHECKBOX COM A COR DA CATEGORIA
                  activeColor: item.categoria.cor,
                  side: const BorderSide(color: Colors.white30, width: 1.5),
                  onChanged: (v) {
                    setState(() => item.concluido = v!);
                    _salvarDados();
                  }
                ),
                title: Text(
                  item.titulo, 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w500,
                    decoration: item.concluido ? TextDecoration.lineThrough : null
                  )
                ),
                // ✅ SUBTÍTULO COM LOCAL/DESCRIÇÃO
                subtitle: Text(
                  "${DateFormat('HH:mm').format(item.dataHora)} - ${item.materia}", 
                  style: const TextStyle(color: Colors.white38, fontSize: 12)
                ),
                iconColor: Colors.white54,
                collapsedIconColor: Colors.white24,
                children: [
                  if (item.observacoes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft, 
                        child: Text(
                          item.observacoes, 
                          style: const TextStyle(color: Colors.white70, fontSize: 14)
                        )
                      ),
                    ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Repetição: ${item.repeticao}", 
                      style: const TextStyle(color: Colors.amber, fontSize: 12)
                    ),
                    // ✅ NOME DA CATEGORIA COLORIDO NO FINAL
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.categoria.cor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        item.categoria.nome.toUpperCase(), 
                        style: TextStyle(color: item.categoria.cor, fontSize: 10, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}