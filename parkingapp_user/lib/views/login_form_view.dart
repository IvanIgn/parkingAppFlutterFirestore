// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:parkingapp_user/blocs/auth/auth_bloc.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/services.dart';

// class LoginFormView extends StatefulWidget {
//   final VoidCallback onLoginSuccess;

//   const LoginFormView({super.key, required this.onLoginSuccess});

//   @override
//   LoginFormViewState createState() => LoginFormViewState();
// }

// class LoginFormViewState extends State<LoginFormView> {
//   // final TextEditingController nameController = TextEditingController();
//   //final TextEditingController personNumController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   //String? personNameError;
//   String? emailError;
//   //String? personNumError;
//   String? passwordError;

//   void _focusInputField() {
//     if (kIsWeb) {
//       Future.delayed(Duration(milliseconds: 100), () {
//         SystemChannels.textInput.invokeMethod('TextInput.show');
//       });
//     }
//   }

//   // Show loading indicator while login is in process
//   Future<void> _showLoadingAndLogin() async {
//     _focusInputField();
//     // Show the loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );

//     // Wait for 2 seconds to simulate a delay before proceeding with login
//     await Future.delayed(const Duration(seconds: 2));

//     //final personName = nameController.text.trim();
//     //final personNum = personNumController.text.trim();
//     final email = emailController.text.trim();
//     final password =
//         passwordController.text.trim(); // Hardcoded password for now
//     //final personName = "personName"; // Hardcoded personName for now

//     setState(() {
//       //   personNameError = personName.isEmpty ? "Fyll i namn" : null;
//       //   // personNumError = personNum.isEmpty ? "Fyll i personnummer" : null;
//       //   emailError = email.isEmpty ? "Fyll i e-postadress" : null;
//       // });
//       emailError = email.isEmpty ? "Fyll i Email" : null;
//       // personNumError = personNum.isEmpty ? "Fyll i personnummer" : null;
//       passwordError = password.isEmpty ? "Fyll i lösenord" : null;
//     });

//     // if (personNameError == null /*&& personNumError == null*/ &&
//     //     emailError == null) {
//     //   // Trigger the login request via AuthBloc
//     //   BlocProvider.of<AuthBloc>(context).add(LoginRequested(
//     //       /*personName: personName,*/ /*personNum: personNum,*/
//     //       email: email
//     //       password: password));
//     // } else {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(
//     //       content: Text("Kontrollera uppgifterna och försök igen"),
//     //     ),
//     //   );
//     // }
//     if (passwordError == null /*&& personNumError == null*/ &&
//         emailError == null) {
//       // Trigger the login request via AuthBloc
//       BlocProvider.of<AuthBloc>(context).add(LoginRequested(
//           personName: "User Name",
//           /*personNum: personNum,*/
//           email: email,
//           password: password));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Kontrollera uppgifterna och försök igen"),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Logga In")),
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthAuthenticated) {
//             // When login is successful, pop the login screen
//             if (Navigator.of(context).canPop()) {
//               Navigator.of(context).pop(); // Close loading dialog
//             }
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("${state.email} har loggats in")),
//             );
//             //  widget.onLoginSuccess(); // Trigger post-login action
//           } else if (state is AuthError) {
//             // Close loading dialog if open
//             if (Navigator.of(context).canPop()) Navigator.of(context).pop();

//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage)),
//             );
//           }
//         },
//         child: SingleChildScrollView(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 400),
//                 child: Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         TextField(
//                           controller: emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: InputDecoration(
//                             labelText: "Email",
//                             errorText: emailError,
//                             border: const OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: passwordController,
//                           obscureText: true,
//                           decoration: InputDecoration(
//                             labelText: "Lösenord",
//                             errorText: passwordError,
//                             border: const OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: _showLoadingAndLogin,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 40,
//                               vertical: 16,
//                             ),
//                             textStyle: const TextStyle(fontSize: 16),
//                           ),
//                           child: const Text("Logga In"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp_user/blocs/auth/auth_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class LoginFormView extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginFormView({super.key, required this.onLoginSuccess});

  @override
  LoginFormViewState createState() => LoginFormViewState();
}

class LoginFormViewState extends State<LoginFormView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  void _focusInputField() {
    if (kIsWeb) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  void _login() {
    _focusInputField();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      emailError = email.isEmpty ? "Fyll i Email" : null;
      passwordError = password.isEmpty ? "Fyll i lösenord" : null;
    });

    if (emailError == null && passwordError == null) {
      // Trigger login event
      BlocProvider.of<AuthBloc>(context).add(LoginRequested(
        personName: "User Name",
        email: email,
        password: password,
      ));

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kontrollera uppgifterna och försök igen"),
        ),
      );
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Logga In")),
  //     body: BlocListener<AuthBloc, AuthState>(
  //       listener: (context, state) {
  //         if (state is AuthAuthenticated) {
  //           // Close loading dialog if open
  //           if (Navigator.of(context).canPop()) {
  //             Navigator.of(context).pop();
  //           }
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text("${state.email} har loggats in")),
  //           );

  //           // Navigate to home after login success
  //           widget.onLoginSuccess();
  //         } else if (state is AuthError) {
  //           // Close loading dialog if open
  //           if (Navigator.of(context).canPop()) {
  //             Navigator.of(context).pop();
  //           }

  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text(state.errorMessage)),
  //           );
  //         }
  //       },
  //       child: SingleChildScrollView(
  //         child: Center(
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: ConstrainedBox(
  //               constraints: const BoxConstraints(maxWidth: 400),
  //               child: Card(
  //                 elevation: 4,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(24.0),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       TextField(
  //                         controller: emailController,
  //                         keyboardType: TextInputType.emailAddress,
  //                         decoration: InputDecoration(
  //                           labelText: "Email",
  //                           errorText: emailError,
  //                           border: const OutlineInputBorder(),
  //                         ),
  //                         onSubmitted: (_) => _login(),
  //                       ),
  //                       const SizedBox(height: 16),
  //                       TextField(
  //                         controller: passwordController,
  //                         obscureText: true,
  //                         decoration: InputDecoration(
  //                           labelText: "Lösenord",
  //                           errorText: passwordError,
  //                           border: const OutlineInputBorder(),
  //                         ),
  //                         onSubmitted: (_) => _login(),
  //                       ),
  //                       const SizedBox(height: 24),
  //                       ElevatedButton(
  //                         onPressed: _login,
  //                         style: ElevatedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 40,
  //                             vertical: 16,
  //                           ),
  //                           textStyle: const TextStyle(fontSize: 16),
  //                         ),
  //                         child: const Text("Logga In"),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logga In")),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Close any open dialogs
            Navigator.of(context).popUntil((route) => route.isFirst);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${state.email} har loggats in")),
            );

            // Navigate to home after login success
            widget.onLoginSuccess();
          } else if (state is AuthError) {
            // Close any loading dialogs
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

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
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            errorText: emailError,
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Lösenord",
                            errorText: passwordError,
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _login,
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
