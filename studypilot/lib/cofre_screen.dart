import 'package:flutter/material.dart';

// --- MODELOS DE DADOS ---
abstract class RegistroCofre {
  final String id;
  final String titulo;
  final String categoria;
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
  static List<RegistroCofre> _storage = [];

  void _validarAcesso() {
    if (_chaveMestra == null) {
      if (_senhaController.text.length < 4) return;
      setState(() { _chaveMestra = _senhaController.text; _autenticado = true; });
    } else {
      if (_senhaController.text == _chaveMestra) {
        setState(() => _autenticado = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chave Incorreta"), backgroundColor: Colors.redAccent));
      }
    }
    _senhaController.clear();
  }

  void _menuGestao() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1F33),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.password, color: Colors.amber),
            title: const Text("Alterar Chave Mestra"),
            onTap: () {
              Navigator.pop(context);
              _dialogNovaSenha();
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text("Bloquear Cofre"),
            onTap: () {
              setState(() => _autenticado = false);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _dialogNovaSenha() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F33),
        title: const Text("Nova Chave", style: TextStyle(color: Colors.amber)),
        content: TextField(controller: c, obscureText: true, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () {
            if(c.text.length >= 4) setState(() => _chaveMestra = c.text);
            Navigator.pop(ctx);
          }, child: const Text("Salvar")),
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
          Text(novo ? "CONFIGURAR COFRE" : "IDENTIFICAÇÃO", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 30),
          TextField(
            controller: _senhaController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: Colors.amber, letterSpacing: 10),
            decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _validarAcesso,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 15)),
            child: Text(novo ? "CADASTRAR" : "ENTRAR", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.all(25),
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("SAFE BOX", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            IconButton(onPressed: _menuGestao, icon: const Icon(Icons.more_vert, color: Colors.white24)),
          ],
        ),
        const Text("DADOS PROTEGIDOS", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        _cat("SENHAS", Icons.vpn_key_rounded),
        _cat("DOCUMENTOS", Icons.badge_rounded),
        _cat("ANOTAÇÕES", Icons.description_rounded),
      ],
    );
  }

  Widget _cat(String t, IconData i) {
    int q = _storage.where((item) => item.categoria == t).length;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DetalheCofre(titulo: t, storage: _storage, onRefresh: () => setState(() {})))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1C1F33), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(i, color: Colors.amber, size: 26),
            const SizedBox(width: 20),
            Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold))),
            Text("$q", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- TELA DE DETALHES ---
class DetalheCofre extends StatefulWidget {
  final String titulo;
  final List<RegistroCofre> storage;
  final VoidCallback onRefresh;
  const DetalheCofre({super.key, required this.titulo, required this.storage, required this.onRefresh});

  @override
  State<DetalheCofre> createState() => _DetalheCofreState();
}

class _DetalheCofreState extends State<DetalheCofre> {
  final _t1 = TextEditingController(), _t2 = TextEditingController(), _t3 = TextEditingController(), _t4 = TextEditingController(), _t5 = TextEditingController();

  void _salvar() {
    if(_t1.text.isEmpty) return;
    setState(() {
      if (widget.titulo == "SENHAS") {
        widget.storage.add(Credencial(id: DateTime.now().toString(), titulo: _t1.text, categoria: widget.titulo, email: _t2.text, senha: _t3.text, telefone: _t4.text, recuperacao: _t5.text));
      } else if (widget.titulo == "DOCUMENTOS") {
        widget.storage.add(Documento(id: DateTime.now().toString(), titulo: _t1.text, categoria: widget.titulo, obs: _t2.text));
      } else {
        widget.storage.add(Nota(id: DateTime.now().toString(), titulo: _t1.text, categoria: widget.titulo, conteudo: _t2.text));
      }
    });
    Navigator.pop(context);
    widget.onRefresh();
    _t1.clear(); _t2.clear(); _t3.clear(); _t4.clear(); _t5.clear();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.storage.where((i) => i.categoria == widget.titulo).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      appBar: AppBar(title: Text(widget.titulo), backgroundColor: Colors.transparent, foregroundColor: Colors.amber, elevation: 0),
      body: list.isEmpty ? const Center(child: Text("Vazio", style: TextStyle(color: Colors.white10))) : 
      ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (c, i) => Card(
          color: const Color(0xFF1C1F33),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(list[i].titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("••••", style: TextStyle(color: Colors.amber)),
            onTap: () => _ver(list[i]),
            onLongPress: () => setState(() { widget.storage.remove(list[i]); widget.onRefresh(); }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: _form,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _ver(RegistroCofre r) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F33),
      title: Text(r.titulo, style: const TextStyle(color: Colors.amber)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r is Credencial) ...[ _row("Usuário", r.email), _row("Senha", r.senha), _row("Telefone", r.telefone), _row("Recuperação", r.recuperacao) ]
          else if (r is Documento) ...[ _row("Obs", r.obs) ]
          else if (r is Nota) ...[ _row("Conteúdo", r.conteudo) ]
        ],
      ),
    ));
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    SelectableText(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  ]));

  void _form() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF1C1F33), builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 25, right: 25, top: 25),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _t1, decoration: const InputDecoration(labelText: "Título")),
        if(widget.titulo == "SENHAS") ...[
          TextField(controller: _t2, decoration: const InputDecoration(labelText: "E-mail/User")),
          TextField(controller: _t3, decoration: const InputDecoration(labelText: "Senha"), obscureText: true),
          TextField(controller: _t4, decoration: const InputDecoration(labelText: "Telefone")),
          TextField(controller: _t5, decoration: const InputDecoration(labelText: "E-mail Recuperação")),
        ] else ...[
          TextField(controller: _t2, decoration: const InputDecoration(labelText: "Conteúdo"), maxLines: 3),
        ],
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _salvar, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 50)), child: const Text("SALVAR", style: TextStyle(color: Colors.black))),
        const SizedBox(height: 20),
      ]),
    ));
  }
}