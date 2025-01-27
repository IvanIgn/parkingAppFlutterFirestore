import 'package:server/router_config.dart';
import 'package:shared/only_import_on_storage_device.dart';
import 'package:shared/shared.dart';

class PersonRepository {
  static final PersonRepository instance = PersonRepository._();
  PersonRepository._();

  final Box<Person> personBox = ServerConfig.instance.store.box<Person>();

  Future<Person> add(Person person) async {
    personBox.put(person, mode: PutMode.insert);

    // above command did not error
    return person;
  }

  Future<Person?> getById(int id) async {
    return personBox.get(id);
  }

  Future<List<Person>> getAll() async {
    return personBox.getAll();
  }

  Future<Person> update(int id, Person newPerson) async {
    personBox.put(newPerson, mode: PutMode.update);
    return newPerson;
  }

  Future<Person?> delete(int id) async {
    Person? person = personBox.get(id);

    if (person != null) {
      personBox.remove(id);
    }

    return person;
  }
}
