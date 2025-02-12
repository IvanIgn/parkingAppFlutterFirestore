import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp_user/blocs/registration/registration_bloc.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final personNumController = TextEditingController();
    final confirmPersonNumController = TextEditingController();
    final emailController = TextEditingController();
    final confirmEmailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // Using ValueNotifier to manage error messages
    final nameErrorNotifier = ValueNotifier<String?>(null);
    final personNumErrorNotifier = ValueNotifier<String?>(null);
    final emailErrorNotifier = ValueNotifier<String?>(null);
    final passwordErrorNotifier = ValueNotifier<String?>(null);

    return Scaffold(
      appBar: AppBar(title: const Text("Registrera Dig")),
      body: SingleChildScrollView(
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
                  child: BlocConsumer<RegistrationBloc, RegistrationState>(
                    listener: (context, state) {
                      if (state is RegistrationSuccess) {
                        // Show success message in SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.successMessage)),
                        );
                        Navigator.of(context).pop(); // Navigate back
                      } else if (state is RegistrationError) {
                        // Show error message in SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is RegistrationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder<String?>(
                            valueListenable: nameErrorNotifier,
                            builder: (context, error, _) {
                              return TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Namn",
                                  errorText: error,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: personNumErrorNotifier,
                            builder: (context, error, _) {
                              return TextField(
                                controller: personNumController,
                                decoration: InputDecoration(
                                  labelText: "Personnummer",
                                  errorText: error,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: personNumErrorNotifier,
                            builder: (context, error, _) {
                              return TextField(
                                controller: confirmPersonNumController,
                                decoration: InputDecoration(
                                  labelText: "Bekräfta personnummer",
                                  errorText: error,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: emailErrorNotifier,
                            builder: (context, error, _) {
                              return TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  errorText: error,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: emailErrorNotifier,
                            builder: (context, error, _) {
                              return TextField(
                                controller: confirmEmailController,
                                decoration: InputDecoration(
                                  labelText: "Bekräfta Email",
                                  errorText: error,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: passwordErrorNotifier,
                            builder: (context, error, _) {
                              return TextField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: "Lösenord",
                                  errorText: error,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: passwordErrorNotifier,
                            builder: (context, error, _) {
                              return TextField(
                                controller: confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: "Bekräfta Lösenord",
                                  errorText: error,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // Validate input fields
                              final name = nameController.text.trim();
                              final personNum = personNumController.text.trim();
                              final confirmPersonNum =
                                  confirmPersonNumController.text.trim();
                              final email = emailController.text.trim();
                              final confirmEmail =
                                  confirmEmailController.text.trim();
                              final password = passwordController.text.trim();
                              final confirmPassword =
                                  confirmPasswordController.text.trim();

                              // Reset error messages
                              nameErrorNotifier.value = null;
                              personNumErrorNotifier.value = null;
                              emailErrorNotifier.value = null;
                              passwordErrorNotifier.value = null;

                              // Validate fields
                              if (name.isEmpty) {
                                nameErrorNotifier.value =
                                    "Namn är obligatoriskt.";
                                return;
                              }

                              if (personNum.isEmpty) {
                                personNumErrorNotifier.value =
                                    "Personnummer är obligatoriskt.";
                                return;
                              }

                              if (personNum != confirmPersonNum) {
                                personNumErrorNotifier.value =
                                    "Personnummer matchar inte.";
                                return;
                              }

                              if (email.isEmpty) {
                                emailErrorNotifier.value =
                                    "Email är obligatoriskt.";
                                return;
                              }

                              if (email != confirmEmail) {
                                emailErrorNotifier.value =
                                    "Email matchar inte.";
                                return;
                              }

                              if (password.isEmpty) {
                                passwordErrorNotifier.value =
                                    "Lösenord är obligatoriskt.";
                                return;
                              }

                              if (password != confirmPassword) {
                                passwordErrorNotifier.value =
                                    "Lösenord matchar inte.";
                                return;
                              }

                              // Dispatch registration event if validation passes
                              context.read<RegistrationBloc>().add(
                                    RegistrationSubmitted(
                                      name: name,
                                      personNum: personNum,
                                      confirmPersonNum: confirmPersonNum,
                                      email: email,
                                      confirmEmail: confirmEmail,
                                      password: password,
                                      confirmPassword: confirmPassword,
                                    ),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text("Registrera"),
                          ),
                        ],
                      );
                    },
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
