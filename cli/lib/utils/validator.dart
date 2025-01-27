class Validator {
// check that nullable string is number
  static bool isNumber(String? value) {
    if (value == null) {
      return false;
    }
    final n = num.tryParse(value);
    return n != null;
  }

  // Validate single string input
  static bool validateStringInput(String? input, String errorMessage) {
    if (!Validator.isString(input) || input == null || input.isEmpty) {
      printError(errorMessage);
      return false;
    }
    return true;
  }

  static bool isString(String? value) {
    return value != null;
  }

  static printError(String message) {
    print('Fel: $message');
  }

  static bool isIndex(String? value, Iterable list) {
    if (!isNumber(value)) {
      return false;
    }
    final index = int.parse(value!);
    return index >= 1 && index < list.length + 1;
  }

  static bool isValidSocialSecurityNumber(String input) {
    // Проверяем, что строка состоит ровно из 12 цифр
    final RegExp ssnPattern = RegExp(r'^\d{12}$');

    // Возвращаем результат проверки по регулярному выражению
    return ssnPattern.hasMatch(input);
  }

  static bool isValidRegistrationNumber(String value) {
    // Add your validation logic here

    final regExp = RegExp(r'^[A-Z]{3}\d{3}$');

    return regExp.hasMatch(value);
  }

  static bool validateNumber(String input) {
    final number = int.tryParse(input);

    return number != null;
  }

  static bool containsSwedishLetters(String input) {
    // Define the set of Swedish characters
    final swedishCharacters = RegExp(r'[åäöÅÄÖ]');

    // Check if the input string contains any of these characters
    return swedishCharacters.hasMatch(input);
  }
}
