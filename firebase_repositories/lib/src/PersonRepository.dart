import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

// String host = Platform.isAndroid ? 'http://10.0.2.2' : 'http://localhost';
// String port = '8080';
// String resource = 'persons';

class PersonRepository {
  static final PersonRepository _instance = PersonRepository._internal();
  static PersonRepository get instance => _instance;
  PersonRepository._internal();

  final db = FirebaseFirestore.instance; // Initialize FirebaseFirestore

  Future<Person> createPerson(Person person) async {
    // await Future.delayed(Duration(seconds: 5));

    await db.collection("persons").doc(person.id).set(person.toJson());

    return person;
  }

  Future<Person> getPersonById(String id) async {
    final snapshot = await db.collection("persons").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      throw Exception("User with id $id not found");
    }

    json["id"] = snapshot.id;

    return Person.fromJson(json);
  }

  Future<List<Person>> getAllPersons() async {
    final snapshots = await db.collection("persons").get();

    final docs = snapshots.docs;

    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;

      return json;
    }).toList();

    return jsons.map((json) => Person.fromJson(json)).toList();
  }

  Future<Person> deletePerson(String id) async {
    final person = await getPersonById(id);

    await db.collection("persons").doc(id).delete();

    return person;
  }

  Future<Person> updatePerson(String id, Person person) async {
    await db.collection("persons").doc(person.id).set(person.toJson());

    return person;
  }
}
