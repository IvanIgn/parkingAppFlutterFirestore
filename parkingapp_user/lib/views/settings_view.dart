import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'dart:convert';
import '../main.dart'; // To access the global isDarkModeNotifier
import '../blocs/auth/auth_bloc.dart'; // Import your AuthBloc

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bekräfta'),
          content: const Text(
              'Är du säker på att du vill ta bort den här profilen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Avbryt'),
            ),
            TextButton(
              onPressed: () async {
                final authBloc = context.read<AuthBloc>(); // Hämta innan pop()

                Navigator.of(context).pop(); // Stäng dialogen först

                final prefs = await SharedPreferences.getInstance();
                final loggedInPersonJson = prefs.getString('loggedInPerson');

                if (loggedInPersonJson != null) {
                  try {
                    final loggedInPerson =
                        json.decode(loggedInPersonJson) as Map<String, dynamic>;
                    final loggedInPersonId = loggedInPerson['id']?.toString();

                    debugPrint('Logged in person ID: $loggedInPersonId');

                    if (loggedInPersonId != null) {
                      await PersonRepository.instance
                          .deletePerson(loggedInPersonId);
                    }
                  } catch (e) {
                    debugPrint('Error deleting person: $e');
                  }
                }

                authBloc.add(
                    LogoutRequested()); // Nu är det säkert att anropa detta
              },
              child: const Text(
                'Ta bort',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadDarkModePreference(); // Ensure the current preference is loaded

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inställningar'),
      ),
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDarkMode, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Välj tema',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SwitchListTile(
                  title: const Text('Mörkt läge'),
                  value: isDarkMode,
                  onChanged: (value) async {
                    final prefs = await SharedPreferences.getInstance();
                    isDarkModeNotifier.value = value; // Update the notifier
                    await prefs.setBool(
                        'isDarkMode', value); // Persist the preference
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tema ändrades till ${value ? 'Mörkt' : 'Ljust'} läge',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red color for delete button
                  ),
                  child: const Text('Ta bort profil'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
