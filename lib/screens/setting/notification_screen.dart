import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/providers/main/reminder_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          return SwitchListTile(
            title: const Text("Restaurant Notification"),
            subtitle: const Text("Daily remainder at 11:00 AM"),
            value: provider.isEnabled,
            onChanged: (value) {
              provider.toggleReminder(value);
            },
          );
        },
      ),
    );
  }
}
