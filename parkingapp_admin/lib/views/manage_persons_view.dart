import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import '../blocs/person/person_bloc.dart';
import 'package:shared/shared.dart';

// THIS CLASS WORKS

class ManagePersonsView extends StatelessWidget {
  const ManagePersonsView({super.key});

  Future<bool> _personNumberExists(String personNumber) async {
    final persons = await PersonRepository.instance.getAllPersons();
    return persons.any((person) => person.personNumber == personNumber);
  }

  void _showAddPersonDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController personNumberController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lägg till person"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Namn'),
                ),
                TextField(
                  controller: personNumberController,
                  decoration: const InputDecoration(labelText: 'Personnummer'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Avbryt"),
            ),
            ElevatedButton(
              onPressed: () async {
                final personNumber = personNumberController.text;
                final name = nameController.text;

                if (await _personNumberExists(personNumber)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Personen $name med detta personnummer $personNumber finns redan"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                final newPerson = Person(
                  name: name,
                  personNumber: personNumber,
                );

                context.read<PersonBloc>().add(AddPersonEvent(newPerson));
                Navigator.of(context).pop();
              },
              child: const Text("Spara"),
            ),
          ],
        );
      },
    );
  }

  void _showEditPersonDialog(BuildContext context, Person person) {
    final TextEditingController nameController =
        TextEditingController(text: person.name);
    final TextEditingController personNumberController =
        TextEditingController(text: person.personNumber);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Uppdatera person"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Namn'),
                ),
                TextField(
                  controller: personNumberController,
                  decoration: const InputDecoration(labelText: 'Personnummer'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Avbryt"),
            ),
            ElevatedButton(
              onPressed: () async {
                final personNumber = personNumberController.text;
                final name = nameController.text;

                if (personNumber != person.personNumber &&
                    await _personNumberExists(personNumber)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Personen $name med detta personnummer $personNumber finns redan"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  return;
                }

                final updatedPerson = Person(
                  id: person.id,
                  name: name,
                  personNumber: personNumber,
                );

                context
                    .read<PersonBloc>()
                    .add(UpdatePersonEvent(updatedPerson));
                Navigator.of(context).pop();
              },
              child: const Text("Spara"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Person person) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bekräfta borttagning"),
          content: Text(
            "Är du säker på att du vill ta bort personen med ID ${person.id}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Avbryt"),
            ),
            ElevatedButton(
              onPressed: () async {
                context.read<PersonBloc>().add(DeletePersonEvent(person.id));
                Navigator.of(context).pop();
              },
              child: const Text("Ta bort"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hantera personer"),
      ),
      body: BlocBuilder<PersonBloc, PersonState>(
        builder: (context, state) {
          if (state is PersonLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PersonErrorState) {
            return Center(
              child: Text(
                'Fel vid hämtning av data: ${state.message}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (state is PersonLoadedState) {
            final personsList = state.persons;
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: personsList.length,
              itemBuilder: (context, index) {
                final person = personsList[index];
                return ListTile(
                  title: Text(
                    'Person ID: ${person.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namn: ${person.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Personnummer: ${person.personNumber}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditPersonDialog(context, person);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, person);
                        },
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 1,
                  color: Colors.black87,
                );
              },
            );
          } else if (state is PersonAddedState ||
              state is PersonUpdatedState ||
              state is PersonDeletedState) {
            return const Center(
              child: Text(
                'List updated',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPersonDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
