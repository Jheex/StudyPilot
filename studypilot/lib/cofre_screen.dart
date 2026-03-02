import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final List<String> fotosPaths;
  final String obs;
  Documento({required super.id, required super.titulo, required super.categoria, required this.obs, required this.fotosPaths});
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
      setState(() { _chaveMestra = input; _autenticado = true; });
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
            TextField(controller: atualCont, obscureText: true, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Senha Atual", labelStyle: TextStyle(color: Colors.white24))),
            TextField(controller: novaCont, obscureText: true, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Nova Senha", labelStyle: TextStyle(color: Colors.white24))),
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
          Text(novo ? "CRIAR ACESSO" : "DIGITE A CHAVE", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
          const SizedBox(height: 30),
          TextField(
            controller: _senhaController, obscureText: true, keyboardType: TextInputType.number,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.amber, letterSpacing: 10),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white.withValues(alpha: 0.05), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              hintText: "••••", hintStyle: const TextStyle(color: Colors.white10)
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
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("SAFE BOX", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text("MODO RESTRITO", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
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
        decoration: BoxDecoration(color: const Color(0xFF1C1F33), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.03))),
        child: Row(
          children: [
            Icon(i, color: Colors.amber, size: 28),
            const SizedBox(width: 20),
            Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
              child: Text("$q", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
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
  final _t1 = TextEditingController(), _t2 = TextEditingController(), 
        _t3 = TextEditingController(), _t4 = TextEditingController(), _t5 = TextEditingController();
  
  List<String> _fotosTemporarias = [];
  final ImagePicker _picker = ImagePicker();

  void _limpar() { _t1.clear(); _t2.clear(); _t3.clear(); _t4.clear(); _t5.clear(); _fotosTemporarias = []; }

  Future<void> _pegarImagem(ImageSource source, StateSetter setModalState) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setModalState(() { _fotosTemporarias.add(image.path); });
    }
  }

  void _salvar({String? editId}) {
    if(_t1.text.isEmpty) return;
    setState(() {
      if (editId != null) widget.storage.removeWhere((item) => item.id == editId);
      final id = editId ?? DateTime.now().toString();

      if (widget.titulo == "SENHAS") {
        widget.storage.add(Credencial(id: id, titulo: _t1.text, categoria: widget.titulo, email: _t2.text, senha: _t3.text, telefone: _t4.text, recuperacao: _t5.text));
      } else if (widget.titulo == "DOCUMENTOS") {
        widget.storage.add(Documento(id: id, titulo: _t1.text, categoria: widget.titulo, obs: _t2.text, fotosPaths: List.from(_fotosTemporarias)));
      } else {
        widget.storage.add(Nota(id: id, titulo: _t1.text, categoria: widget.titulo, conteudo: _t2.text));
      }
    });
    Navigator.pop(context);
    widget.onRefresh();
    _limpar();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.storage.where((i) => i.categoria == widget.titulo).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      appBar: AppBar(title: Text(widget.titulo), backgroundColor: Colors.transparent, foregroundColor: Colors.amber, elevation: 0),
      body: list.isEmpty ? const Center(child: Text("Nenhum registro", style: TextStyle(color: Colors.white10))) : 
      ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (c, i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: const Color(0xFF1C1F33), borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(list[i].titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            subtitle: Text(list[i] is Documento ? "${(list[i] as Documento).fotosPaths.length} anexos" : "Toque para ver", style: const TextStyle(color: Colors.amber, fontSize: 10)),
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
      title: Text(r.titulo, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r is Documento && r.fotosPaths.isNotEmpty) ...[
              SizedBox(
                height: 250, width: double.maxFinite,
                child: PageView.builder(
                  itemCount: r.fotosPaths.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(r.fotosPaths[index]), fit: BoxFit.contain)),
                  ),
                ),
              ),
              const Center(child: Text("Arraste para o lado", style: TextStyle(fontSize: 10, color: Colors.white24))),
              const SizedBox(height: 15),
            ],
            if (r is Credencial) ...[ _row("Usuário", r.email), _row("Senha", r.senha), _row("Telefone", r.telefone), _row("Recuperação", r.recuperacao) ]
            else if (r is Documento) ...[ _row("Observações", r.obs) ]
            else if (r is Nota) ...[ _row("Conteúdo", r.conteudo) ]
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("FECHAR", style: TextStyle(color: Colors.amber)))],
    ));
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l.toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    SelectableText(v, style: const TextStyle(color: Colors.white, fontSize: 15)),
  ]));

  void _form({RegistroCofre? r}) {
    if (r != null) {
      _t1.text = r.titulo;
      if (r is Credencial) { _t2.text = r.email; _t3.text = r.senha; _t4.text = r.telefone; _t5.text = r.recuperacao; }
      else if (r is Documento) { _t2.text = r.obs; _fotosTemporarias = List.from(r.fotosPaths); }
      else if (r is Nota) { _t2.text = r.conteudo; }
    } else { _limpar(); }

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: const Color(0xFF121421), 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), 
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 30, right: 30, top: 30),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(r == null ? "ADICIONAR NOVO" : "EDITAR REGISTRO", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _t1, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Título", labelStyle: TextStyle(color: Colors.white24))),
          if(widget.titulo == "SENHAS") ...[
            TextField(controller: _t2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Usuário/E-mail", labelStyle: TextStyle(color: Colors.white24))),
            TextField(controller: _t3, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Senha", labelStyle: TextStyle(color: Colors.white24))),
            TextField(controller: _t4, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Telefone", labelStyle: TextStyle(color: Colors.white24))),
            TextField(controller: _t5, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Cód. Recuperação", labelStyle: TextStyle(color: Colors.white24))),
          ] else if (widget.titulo == "DOCUMENTOS") ...[
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => _pegarImagem(ImageSource.camera, setModalState), icon: const Icon(Icons.camera_alt, color: Colors.black), label: const Text("CÂMERA", style: TextStyle(color: Colors.black)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(onPressed: () => _pegarImagem(ImageSource.gallery, setModalState), icon: const Icon(Icons.image, color: Colors.black), label: const Text("GALERIA", style: TextStyle(color: Colors.black)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white))),
            ]),
            if (_fotosTemporarias.isNotEmpty) Container(
              height: 100, margin: const EdgeInsets.symmetric(vertical: 15),
              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _fotosTemporarias.length, itemBuilder: (context, idx) => Stack(children: [
                Container(width: 90, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10), image: DecorationImage(image: FileImage(File(_fotosTemporarias[idx])), fit: BoxFit.cover))),
                Positioned(right: 0, top: 0, child: GestureDetector(onTap: () => setModalState(() => _fotosTemporarias.removeAt(idx)), child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.red, size: 20)))),
              ])),
            ),
            TextField(controller: _t2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Observações", labelStyle: TextStyle(color: Colors.white24)), maxLines: 2),
          ] else ...[
            TextField(controller: _t2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Anotação", labelStyle: TextStyle(color: Colors.white24)), maxLines: 5),
          ],
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _salvar(editId: r?.id), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), 
            child: Text(r == null ? "SALVAR" : "ATUALIZAR", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ),
          const SizedBox(height: 30),
        ]),
      ),
    )));
  }

  void _confirmarExcluir(RegistroCofre r) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F33),
      title: const Text("Excluir item?", style: TextStyle(color: Colors.white)),
      content: Text("Tem certeza que deseja apagar '${r.titulo}'?", style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NÃO", style: TextStyle(color: Colors.white24))),
        TextButton(onPressed: () { setState(() => widget.storage.remove(r)); widget.onRefresh(); Navigator.pop(ctx); }, child: const Text("SIM", style: TextStyle(color: Colors.redAccent))),
      ],
    ));
  }
}