import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PersonRepository personRepository;
  final AuthRepository authRepository = AuthRepository();

  AuthBloc({required this.personRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        if (state is! AuthLoggedOut) {
          emit(AuthLoggedOut());
        }
        return;
      }

      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('persons')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        print("❌ No Firestore document found for user ID: ${firebaseUser.uid}");
        emit(AuthError(
            errorMessage:
                "Ingen användardata hittades. Vänligen kontakta supporten."));
        return;
      }

      final userData = userDoc.data() ?? {};
      String userName = userData['name'] ?? 'Användare'; // Default if missing

      // Update display name ONLY if it's different
      if (firebaseUser.displayName != userName) {
        await firebaseUser.updateDisplayName(userName);
      }

      // Emit state **only if it has changed**
      if (state is! AuthAuthenticated ||
          (state as AuthAuthenticated).name != userName) {
        emit(AuthAuthenticated(
          name: userName,
          email: firebaseUser.email ?? '',
          password: '', // Never store password in state
          personNumber: '',
        ));
      }
    } catch (e) {
      print("⚠️ Error checking authentication status: $e");
      if (state is! AuthError) {
        emit(AuthError(
            errorMessage: "Ett fel uppstod vid kontroll av inloggning."));
      }
    }
  }

  // Future<void> _onLoginRequested(
  //     LoginRequested event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());

  //   try {
  //     UserCredential userCredential = await authRepository.login(
  //         email: event.email, password: event.password);

  //     User? firebaseUser = userCredential.user;
  //     if (firebaseUser == null) {
  //       emit(AuthError(
  //           errorMessage: "Inloggningsfel. Användare hittades inte."));
  //       return;
  //     }

  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('persons')
  //         .doc(firebaseUser.uid)
  //         .get();

  //     if (!userDoc.exists || userDoc.data() == null) {
  //       emit(AuthError(errorMessage: "Inga användare hittades i databasen."));
  //       return;
  //     }

  //     final userData = userDoc.data() ?? {};
  //     String name = userData['name'] ?? 'Okänd användare';
  //     String email = firebaseUser.email ?? '';
  //     String personNumber = userData['personNumber'] ?? '';

  //     print("✅ LOGIN SUCCESS: $email ($name)");

  //     final loggedInPerson = userData;
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('loggedInPerson', json.encode(loggedInPerson));
  //     await prefs.setString(
  //         'loggedInName', json.encode(loggedInPerson['name']));
  //     await prefs.setString(
  //         'loggedInPersonNum', json.encode(loggedInPerson['personNumber']));
  //     await prefs.setString(
  //         'loggedInPersonEmail', json.encode(loggedInPerson['email']));
  //     await prefs.setString(
  //         'loggedInPersonAuthId', json.encode(loggedInPerson['authId']));

  //     emit(AuthAuthenticated(
  //       name: name,
  //       email: email,
  //       password: '',
  //       personNumber: personNumber,
  //     ));
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'Inloggning misslyckades: $e'));
  //   }
  // }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      UserCredential userCredential = await authRepository.login(
          email: event.email, password: event.password);

      User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        emit(AuthError(
            errorMessage: "Inloggningsfel. Användare hittades inte."));
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('persons')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        emit(AuthError(errorMessage: "Inga användare hittades i databasen."));
        return;
      }

      final userData = userDoc.data() ?? {};
      String name = userData['name'] ?? 'Okänd användare';
      String email = firebaseUser.email ?? '';
      String personNumber = userData['personNumber'] ?? '';

      print("✅ LOGIN SUCCESS: $email ($name)");

      // Save logged-in user data to SharedPreferences
      final loggedInPerson = {
        'name': name,
        'personNumber': personNumber,
        'email': email,
        'authId': firebaseUser.uid, // Ensure authId is set
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedInPerson', json.encode(loggedInPerson));

      emit(AuthAuthenticated(
        name: name,
        email: email,
        password: '',
        personNumber: personNumber,
      ));
    } catch (e) {
      emit(AuthError(errorMessage: 'Inloggning misslyckades: $e'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await authRepository.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(errorMessage: 'Ett fel uppstod under utloggning: $e'));
    }
  }
}


  // Future<void> _onLoginRequested(
  //     LoginRequested event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());
  //   try {
  //     //await authRepository = AuthRepository();
  //     await authRepository.login(email: event.email, password: event.password);

  //     final persons = await personRepository.getAllPersons();
  //     final personMap = {for (var p in persons) p.email: p};

  //     if (!personMap.containsKey(event.email) ||
  //         personMap[event.email]?.name != event.personName) {
  //       emit(AuthError(
  //           errorMessage:
  //               'Personen "${event.personName}" med email "${event.email}" är inte registrerad.'));
  //       return; // No need to emit `AuthLoggedOut()`
  //     }

  //     final loggedInPerson = personMap[event.email]!;
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString(
  //         'loggedInPerson', json.encode(loggedInPerson.toJson()));

  //     emit(AuthAuthenticated(
  //       name: loggedInPerson.name,
  //       email: loggedInPerson.email,
  //       password: '', // Add the password argument here
  //     ));
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'An error occurred: $e'));
  //   }
  // }

  // Future<void> _onCheckAuthStatus(
  //     CheckAuthStatus event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final loggedInPerson = prefs.getString('loggedInPerson');
  //     if (loggedInPerson != null) {
  //       final personData = json.decode(loggedInPerson);
  //       emit(AuthAuthenticated(
  //           name: personData['name'],
  //           // personNumber: personData['personNumber'],
  //           email: personData['email'],
  //           password: personData['password']));
  //     } else {
  //       emit(AuthLoggedOut());
  //     }
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'Error checking authentication status: $e'));
  //     emit(AuthLoggedOut()); // Reset to a retryable state
  //   }
  // }


  // Future<void> _onLoginRequested(
  //     //   LoginRequested event, Emitter<AuthState> emit) async {
  //     // emit(AuthLoading());
  //     // try {
  //     //   final persons = await personRepository.getAllPersons();
  //     //   final personMap = {for (var p in persons) p.personNumber: p};

  //     //   if (!personMap.containsKey(event.personNum) ||
  //     //       personMap[event.personNum]?.name != event.personName) {
  //     //     emit(AuthError(
  //     //         errorMessage:
  //     //             'Personen "${event.personName}" med personnummer "${event.personNum}" är inte registrerad.'));
  //     //     emit(AuthLoggedOut()); // Allow retry without delay
  //     //     return;
  //     //   }

  //     //   final loggedInPerson = personMap[event.personNum]!;
  //     //   final prefs = await SharedPreferences.getInstance();
  //     //   await prefs.setString(
  //     //       'loggedInPerson', json.encode(loggedInPerson.toJson()));

  //     LoginRequested event,
  //     Emitter<AuthState> emit) async {
  //   emit(AuthLoading());
  //   try {
  //     final persons = await personRepository.getAllPersons();
  //     final personMap = {for (var p in persons) p.email: p};

  //     if (!personMap.containsKey(event.email) ||
  //         personMap[event.email]?.name != event.personName) {
  //       emit(AuthError(
  //           errorMessage:
  //               'Personen "${event.personName}" med email "${event.email}" är inte registrerad.'));
  //       emit(AuthLoggedOut()); // Allow retry without delay
  //       return;
  //     }

  //     final loggedInPerson = personMap[event.email]!;
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString(
  //         'loggedInPerson', json.encode(loggedInPerson.toJson()));

  //     emit(AuthAuthenticated(
  //       name: loggedInPerson.name,
  //       // personNumber: loggedInPerson.personNumber,
  //       email: loggedInPerson.email,
  //     ));
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'An error occurred: $e'));
  //     emit(AuthLoggedOut()); // Allow retry without delay
  //   }
  // }


    // Future<void> _onLoginRequested(
  //     LoginRequested event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());

  //   print(
  //       "🔍 Debugging Login Input: Email = '${event.email}', Password = '${event.password}'");

  //   if (event.email.isEmpty || event.password.isEmpty) {
  //     emit(AuthError(errorMessage: 'Email and password are required.'));
  //     return;
  //   }

  //   try {
  //     await authRepository.login(email: event.email, password: event.password);

  //     final persons = await personRepository.getAllPersons();
  //     final personMap = {for (var p in persons) p.email: p};

  //     if (!personMap.containsKey(event.email) ||
  //         personMap[event.email]?.name != event.personName) {
  //       emit(AuthError(
  //           errorMessage:
  //               'Personen "${event.personName}" med email "${event.email}" är inte registrerad.'));
  //       return;
  //     }

  //     final loggedInPerson = personMap[event.email]!;
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString(
  //         'loggedInPerson', json.encode(loggedInPerson.toJson()));

  //     emit(AuthAuthenticated(
  //       name: loggedInPerson.name,
  //       email: loggedInPerson.email,
  //       password: '', // Remove storing passwords locally
  //     ));
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'An error occurred: $e'));
  //   }
  // }

  
  // Future<void> _onLoginRequested(
  //     LoginRequested event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());

  //   print(
  //       "🔍 Debugging Login Input: Email = '${event.email}', Password = '${event.password}', Name = '${event.personName}' ");

  //   try {
  //     // 1️⃣ Login user with FirebaseAuth
  //     UserCredential userCredential = await authRepository.login(
  //         email: event.email, password: event.password);

  //     User? firebaseUser = userCredential.user;
  //     if (firebaseUser == null) {
  //       emit(AuthError(
  //           errorMessage: "Inloggningsfel. Användare hittades inte."));
  //       return;
  //     }

  //     final DocumentSnapshot<Map<String, dynamic>> userDoc =
  //         await FirebaseFirestore.instance
  //             .collection('persons')
  //             .doc(firebaseUser.uid)
  //             .get();

  //     if (!userDoc.exists) {
  //       emit(AuthError(
  //           errorMessage:
  //               "Inga användare hittades i databasen for detta email."));
  //       return;
  //     }

  //     final userData = userDoc.data() as Map<String, dynamic>;
  //     print("📢 Firestore User Data Retrieved: $userData");

  //     emit(AuthAuthenticated(
  //       name: userData['name'] ?? 'Okänd användare',
  //       email: firebaseUser.email ?? '',
  //       password: '',
  //     ));
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'Inloggning misslyckades: $e'));
  //   }
  // }



    // Future<void> _onLoginRequested(
  //     LoginRequested event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());

  //   print(
  //       "🔍 Debugging Login Input: Email = '${event.email}', Password = '${event.password}', Name = '${event.personName}' ");

  //   try {
  //     // 1️⃣ Login user with FirebaseAuth
  //     UserCredential userCredential = await authRepository.login(
  //         email: event.email, password: event.password);

  //     User? firebaseUser = userCredential.user;
  //     if (firebaseUser == null) {
  //       emit(AuthError(
  //           errorMessage: "Inloggningsfel. Användare hittades inte."));
  //       return;
  //     }

  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('persons')
  //         .doc(firebaseUser.uid)
  //         .get();

  //     if (!userDoc.exists || userDoc.data() == null) {
  //       print(
  //           "❌ No user document found in Firestore for UID: ${firebaseUser.uid}");
  //       emit(AuthError(
  //           errorMessage:
  //               "Inga användare hittades i databasen för detta email."));
  //       return;
  //     }

  //     final userData = userDoc.data() ?? {};
  //     print("📢 Firestore User Data Retrieved: $userData");

  //     String name = userData['name'] ?? 'Okänd användare'; // Default if missing
  //     String email = firebaseUser.email ?? '';

  //     emit(AuthAuthenticated(
  //       name: name,
  //       email: email,
  //       password: '',
  //     ));
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'Inloggning misslyckades: $e'));
  //   }
  // }

  // Future<void> _onLoginRequested(
  //     LoginRequested event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());

  //   print(
  //       "🔍 Debugging Login Input: Email = '${event.email}', Password = '${event.password}', Name = '${event.personName}' ");

  //   try {
  //     // 1️⃣ Login user with FirebaseAuth
  //     UserCredential userCredential = await authRepository.login(
  //         email: event.email, password: event.password);

  //     User? firebaseUser = userCredential.user;
  //     if (firebaseUser == null) {
  //       emit(AuthError(
  //           errorMessage: "Inloggningsfel. Användare hittades inte."));
  //       return;
  //     }

  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('persons')
  //         .doc(firebaseUser.uid)
  //         .get();

  //     if (!userDoc.exists || userDoc.data() == null) {
  //       print(
  //           "❌ No user document found in Firestore for UID: ${firebaseUser.uid}");
  //       emit(AuthError(
  //           errorMessage:
  //               "Inga användare hittades i databasen för detta email."));
  //       return;
  //     }

  //     final userData = userDoc.data() ?? {};
  //     print("📢 Firestore User Data Retrieved: $userData");

  //     String name = userData['name'] ?? 'Okänd användare'; // Default if missing
  //     String email = firebaseUser.email ?? '';

  //     emit(AuthAuthenticated(
  //       name: name,
  //       email: email,
  //       password: '',
  //     ));

  //     // 🔥 Add this to update authentication state
  //     add(CheckAuthStatus());
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'Inloggning misslyckades: $e'));
  //   }
  // }


  // Future<void> _onCheckAuthStatus(
  //     CheckAuthStatus event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());

  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       emit(AuthAuthenticated(
  //           name: user.displayName ?? 'Användare',
  //           email: user.email ?? '',
  //           password: ''));
  //       User? firebaseUser = FirebaseAuth.instance.currentUser;
  //       if (firebaseUser != null) {
  //         final userDoc = await FirebaseFirestore.instance
  //             .collection('persons')
  //             .doc(firebaseUser.uid)
  //             .get();
  //         final userData = userDoc.data() ?? {};
  //         if (userData.containsKey('name')) {
  //           await firebaseUser.updateDisplayName(userData['name']);
  //           await firebaseUser.reload(); // Ensure changes take effect
  //         }
  //       }
  //     } else {
  //       emit(AuthLoggedOut());
  //     }
  //   } catch (e) {
  //     emit(AuthError(errorMessage: 'Error checking authentication status: $e'));
  //     emit(AuthLoggedOut());
  //   }
  // }