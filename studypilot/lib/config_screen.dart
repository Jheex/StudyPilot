import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Como esta tela é chamada via Navigator.push (uma tela sobre a outra),
    // aqui usamos Scaffold para ter o botão de "voltar" automático.
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Configurações", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildConfigItem(Icons.person_outline, "Perfil do Piloto", "Nome, foto e conta"),
          _buildConfigItem(Icons.dark_mode_outlined, "Aparência", "Temas e cores"),
          _buildConfigItem(Icons.notifications_none_rounded, "Notificações", "Alertas de estudo e agenda"),
          const Divider(color: Colors.white10, height: 40),
          _buildConfigItem(Icons.info_outline, "Sobre o StudyPilot", "Versão 1.0.0"),
          _buildConfigItem(Icons.logout, "Sair", "Encerrar sessão atual", color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildConfigItem(IconData icon, String title, String sub, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white12),
      onTap: () {},
    );
  }
}