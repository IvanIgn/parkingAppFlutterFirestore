import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp_user/blocs/auth/auth_bloc.dart';

class LoginFormView extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginFormView({super.key, required this.onLoginSuccess});

  @override
  LoginFormViewState createState() => LoginFormViewState();
}

class LoginFormViewState extends State<LoginFormView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personNumController = TextEditingController();

  String? personNameError;
  String? personNumError;

  // Show loading indicator while login is in process
  Future<void> _showLoadingAndLogin() async {
    // Show the loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Wait for 2 seconds to simulate a delay before proceeding with login
    await Future.delayed(const Duration(seconds: 2));

    final personName = nameController.text.trim();
    final personNum = personNumController.text.trim();

    setState(() {
      personNameError = personName.isEmpty ? "Ogiltigt namn" : null;
      personNumError = personNum.isEmpty ? "Personnummer krävs" : null;
    });

    if (personNameError == null && personNumError == null) {
      // Trigger the login request via AuthBloc
      BlocProvider.of<AuthBloc>(context).add(LoginRequested(
        personName: personName,
        personNum: personNum,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kontrollera uppgifterna och försök igen"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logga In")),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // When login is successful, pop the login screen
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); // Close the current screen
            }
            //  widget.onLoginSuccess(); // Trigger post-login action
          } else if (state is AuthError) {
            // Close loading dialog if open
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Namn",
                            errorText: personNameError,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: personNumController,
                          decoration: InputDecoration(
                            labelText: "Personnummer",
                            errorText: personNumError,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _showLoadingAndLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text("Logga In"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
