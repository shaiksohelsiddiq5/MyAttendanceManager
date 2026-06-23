import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            "Support & Information",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF9B91FF)),
                  title: const Text("Help & Support"),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pushNamed(context, "/help-support");
                  },
                ),
                const Divider(height: 1, indent: 56, endIndent: 16, color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF00BFA5)),
                  title: const Text("About App"),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pushNamed(context, "/about");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}