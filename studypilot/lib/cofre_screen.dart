import 'package:flutter/material.dart';

// --- MODELOS DE DADOS ---
abstract class RegistroCofre {
  final String id, titulo, categoria;
  RegistroCofre({required this.id, required this.titulo, required this.categoria});
}

class Credencial extends RegistroCofre {
  final String email, senha, telefone, recuperacao;
  Credencial({required super.id, required super.titulo, required super.categoria, 
    required this.email, required this.senha, required this.telefone, required this.recuperacao});
}

class Documento extends RegistroCofre {
  final String obs;
  Documento({required super.id, required super.titulo, required super.categoria, required this.obs});
}

class Nota extends RegistroCofre {
  final String conteudo;
  Nota({required super.id, required super.titulo, required super.categoria, required this.conteudo});
}

// --- TELA PRINCIPAL ---
class CofreScreen extends StatefulWidget {
  const CofreScreen({super.key});

  @override
  State<CofreScreen> createState() => _CofreScreenState();
}

class _CofreScreenState extends State<CofreScreen> {
  final TextEditingController _senhaController = TextEditingController();
  
  static String? _chaveMestra; 
  bool _autenticado = false;
  static final List<RegistroCofre> _storage = [];

  void _validarAcesso() {
    final input = _senhaController.text;
    if (_chaveMestra == null) {
      if (input.length < 4) return;
      setState(() {
        _chaveMestra = input;
        _autenticado = true;
      });
    } else {
      if (input == _chaveMestra) {
        setState(() => _autenticado = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chave Incorreta"), backgroundColor: Colors.redAccent)
        );
      }
    }
    _senhaController.clear();
  }

  void _dialogAlterarSenha() {
    final atualCont = TextEditingController();
    final novaCont = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F33),
        title: const Text("SEGURANÇA", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: atualCont, 
              obscureText: true, 
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Senha Atual", labelStyle: TextStyle(color: Colors.white24)),
            ),
            TextField(
              controller: novaCont, 
              obscureText: true, 
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Nova Senha", labelStyle: TextStyle(color: Colors.white24)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              if (atualCont.text == _chaveMestra && novaCont.text.length >= 4) {
                setState(() => _chaveMestra = novaCont.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Senha atualizada!")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Senha incorreta ou curta.")));
              }
            },
            child: const Text("CONFIRMAR", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      body: _autenticado ? _buildHome() : _buildLock(),
    );
  }

  Widget _buildLock() {
    bool novo = _chaveMestra == null;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(novo ? Icons.shield_outlined : Icons.lock_person_rounded, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          Text(novo ? "CRIAR ACESSO" : "DIGITE A CHAVE", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 30),
          TextField(
            controller: _senhaController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: Colors.amber, letterSpacing: 10),
            decoration: InputDecoration(
              filled: true, 
              fillColor: Colors.white.withValues(alpha: 0.05), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              hintText: "••••",
              hintStyle: const TextStyle(color: Colors.white10)
            ),
            onSubmitted: (_) => _validarAcesso(),
          ),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _validarAcesso,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(novo ? "CONFIGURAR" : "DESBLOQUEAR", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SAFE BOX", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  Text("MODO RESTRITO", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.white24),
                color: const Color(0xFF1C1F33),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1, child: Text("Alterar Senha", style: TextStyle(color: Colors.white, fontSize: 13))),
                  const PopupMenuItem(value: 2, child: Text("Bloquear Agora", style: TextStyle(color: Colors.redAccent, fontSize: 13))),
                ],
                onSelected: (val) {
                  if (val == 1) _dialogAlterarSenha();
                  if (val == 2) setState(() => _autenticado = false);
                },
              )
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              _cat("SENHAS", Icons.vpn_key_rounded),
              _cat("DOCUMENTOS", Icons.badge_rounded),
              _cat("ANOTAÇÕES", Icons.description_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cat(String t, IconData i) {
    int q = _storage.where((item) => item.categoria == t).length;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DetalheCofre(titulo: t, storage: _storage, onRefresh: () => setState(() {})))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F33), 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.white.withValues(alpha: 0.03))
        ),
        child: Row(
          children: [
            Icon(i, color: Colors.amber, size: 28),
            const SizedBox(width: 20),
            Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text("$q", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TELA DE DETALHES COM EDIÇÃO E EXCLUSÃO ---
class DetalheCofre extends StatefulWidget {
  final String titulo;
  final List<RegistroCofre> storage;
  final VoidCallback onRefresh;
  const DetalheCofre({super.key, required this.titulo, required this.storage, required this.onRefresh});

  @override
  State<DetalheCofre> createState() => _DetalheCofreState();
}

class _DetalheCofreState extends State<DetalheCofre> {
  final _t1 = TextEditingController(), _t2 = TextEditingController(), 
        _t3 = TextEditingController(), _t4 = TextEditingController(), _t5 = TextEditingController();

  void _limpar() { _t1.clear(); _t2.clear(); _t3.clear(); _t4.clear(); _t5.clear(); }

  void _salvar({String? editId}) {
    if(_t1.text.isEmpty) return;
    setState(() {
      if (editId != null) widget.storage.removeWhere((item) => item.id == editId);
      final id = editId ?? DateTime.now().toString();

      if (widget.titulo == "SENHAS") {
        widget.storage.add(Credencial(id: id, titulo: _t1.text, categoria: widget.titulo, email: _t2.text, senha: _t3.text, telefone: _t4.text, recuperacao: _t5.text));
      } else if (widget.titulo == "DOCUMENTOS") {
        widget.storage.add(Documento(id: id, titulo: _t1.text, categoria: widget.titulo, obs: _t2.text));
      } else {
        widget.storage.add(Nota(id: id, titulo: _t1.text, categoria: widget.titulo, conteudo: _t2.text));
      }
    });
    Navigator.pop(context);
    widget.onRefresh();
    _limpar();
  }

  void _confirmarExcluir(RegistroCofre r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F33),
        title: const Text("Excluir?", style: TextStyle(color: Colors.redAccent)),
        content: Text("Apagar '${r.titulo}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NÃO")),
          TextButton(onPressed: () {
            setState(() => widget.storage.remove(r));
            widget.onRefresh();
            Navigator.pop(ctx);
          }, child: const Text("SIM", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.storage.where((i) => i.categoria == widget.titulo).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      appBar: AppBar(title: Text(widget.titulo), backgroundColor: Colors.transparent, foregroundColor: Colors.amber),
      body: list.isEmpty ? const Center(child: Text("Nenhum registro", style: TextStyle(color: Colors.white10))) : 
      ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (c, i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: const Color(0xFF1C1F33), borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(list[i].titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text("••••••••", style: TextStyle(color: Colors.amber, fontSize: 10)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white24), onPressed: () => _form(r: list[i])),
                IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: () => _confirmarExcluir(list[i])),
              ],
            ),
            onTap: () => _ver(list[i]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.amber, onPressed: () => _form(), child: const Icon(Icons.add, color: Colors.black)),
    );
  }

  void _ver(RegistroCofre r) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(r.titulo, style: const TextStyle(color: Colors.amber, fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r is Credencial) ...[ _row("Usuário", r.email), _row("Senha", r.senha), _row("Telefone", r.telefone), _row("Recuperação", r.recuperacao) ]
            else if (r is Documento) ...[ _row("Obs", r.obs) ]
            else if (r is Nota) ...[ _row("Conteúdo", r.conteudo) ]
          ],
        ),
      ),
    ));
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l.toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 9)),
    const SizedBox(height: 4),
    SelectableText(v, style: const TextStyle(color: Colors.white, fontSize: 15)),
  ]));

  void _form({RegistroCofre? r}) {
    if (r != null) {
      _t1.text = r.titulo;
      if (r is Credencial) { _t2.text = r.email; _t3.text = r.senha; _t4.text = r.telefone; _t5.text = r.recuperacao; }
      else if (r is Documento) { _t2.text = r.obs; }
      else if (r is Nota) { _t2.text = r.conteudo; }
    } else { _limpar(); }

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: const Color(0xFF121421), 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), 
      builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 30, right: 30, top: 30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(r == null ? "NOVO ITEM" : "EDITAR ITEM", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(controller: _t1, decoration: const InputDecoration(labelText: "Título")),
        if(widget.titulo == "SENHAS") ...[
          TextField(controller: _t2, decoration: const InputDecoration(labelText: "E-mail / Usuário")),
          TextField(controller: _t3, decoration: const InputDecoration(labelText: "Senha"), obscureText: true),
          TextField(controller: _t4, decoration: const InputDecoration(labelText: "Telefone")),
          TextField(controller: _t5, decoration: const InputDecoration(labelText: "Recuperação")),
        ] else ...[
          TextField(controller: _t2, decoration: const InputDecoration(labelText: "Conteúdo / Obs"), maxLines: 4),
        ],
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => _salvar(editId: r?.id), 
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), 
          child: Text(r == null ? "SALVAR NO COFRE" : "ATUALIZAR DADOS", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
        ),
        const SizedBox(height: 30),
      ]),
    ));
  }
}