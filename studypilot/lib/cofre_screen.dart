import 'package:flutter/material.dart';

class CofreScreen extends StatefulWidget {
  const CofreScreen({super.key});

  @override
  State<CofreScreen> createState() => _CofreScreenState();
}

class _CofreScreenState extends State<CofreScreen> {
  final TextEditingController _senhaController = TextEditingController();
  
  // Simulação de persistência (Idealmente, você usaria shared_preferences no futuro)
  static String? _senhaCadastrada; 
  bool _estaAutenticado = false;

  void _processarSenha() {
    String senhaDigitada = _senhaController.text;

    if (_senhaCadastrada == null) {
      // CENÁRIO 1: CADASTRO (Primeira vez)
      if (senhaDigitada.length < 4) {
        _mostrarAlerta("A senha deve ter pelo menos 4 caracteres.");
        return;
      }
      setState(() {
        _senhaCadastrada = senhaDigitada;
        _estaAutenticado = true;
      });
      _mostrarAlerta("Senha cadastrada com sucesso! 🛡️");
    } else {
      // CENÁRIO 2: LOGIN (Já possui senha)
      if (senhaDigitada == _senhaCadastrada) {
        setState(() {
          _estaAutenticado = true;
        });
      } else {
        _mostrarAlerta("Senha incorreta! Acesso negado.");
      }
    }
    _senhaController.clear();
  }

  void _mostrarAlerta(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: const Color(0xFF1C1F33)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se estiver autenticado, mostra o conteúdo do Cofre
    if (_estaAutenticado) {
      return _buildConteudoCofre();
    }

    // Caso contrário, mostra a tela de bloqueio (Cadastro ou Login)
    return _buildTelaBloqueio();
  }

  // --- TELA DE BLOQUEIO / LOGIN ---
  Widget _buildTelaBloqueio() {
    bool jaTemSenha = _senhaCadastrada != null;

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person_rounded, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          Text(
            jaTemSenha ? "IDENTIFICAÇÃO NECESSÁRIA" : "CONFIGURAR COFRE",
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            jaTemSenha 
              ? "Digite sua chave mestra para acessar." 
              : "Defina uma senha para proteger seus documentos.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _senhaController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 10, color: Colors.amber),
            decoration: InputDecoration(
              hintText: "••••",
              hintStyle: const TextStyle(color: Colors.white10),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processarSenha,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(jaTemSenha ? "ENTRAR" : "CADASTRAR SENHA"),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTEÚDO INTERNO DO COFRE ---
  Widget _buildConteudoCofre() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DADOS PROTEGIDOS", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10)),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white24, size: 20),
                onPressed: () => setState(() => _estaAutenticado = false),
              )
            ],
          ),
          const SizedBox(height: 20),
          _buildItemCofre("Senhas", "12 registros", Icons.password_rounded),
          _buildItemCofre("Documentos (PDF)", "3 arquivos", Icons.description_rounded),
          _buildItemCofre("Cartões", "2 salvos", Icons.credit_card_rounded),
          _buildItemCofre("Notas Secretas", "5 notas", Icons.sticky_note_2_rounded),
        ],
      ),
    );
  }

  Widget _buildItemCofre(String titulo, String subtitulo, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F33),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.amber, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitulo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white12, size: 14),
        ],
      ),
    );
  }
}