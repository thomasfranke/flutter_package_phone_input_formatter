import '/exports.dart';

class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class PhoneNumberModel {
  String isoCode;
  String dialCode;
  String number;

  PhoneNumberModel({required this.isoCode, required this.dialCode, required this.number});

  factory PhoneNumberModel.fromCompleteNumber({required String completeNumber}) {
    if (completeNumber == "") {
      return PhoneNumberModel(isoCode: "", dialCode: "", number: "");
    }

    try {
      Country country = getCountry(completeNumber);
      String number;
      if (completeNumber.startsWith('+')) {
        number = completeNumber.substring(1 + country.dialCode.length + country.regionCode.length);
      } else {
        number = completeNumber.substring(country.dialCode.length + country.regionCode.length);
      }
      return PhoneNumberModel(isoCode: country.isoCode, dialCode: country.dialCode + country.regionCode, number: number);
    } on InvalidCharactersException {
      rethrow;
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      return PhoneNumberModel(isoCode: "", dialCode: "", number: "");
    }
  }

  String get completeNumber {
    return dialCode + number;
  }

  static Country getCountry(String phoneNumber) {
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+0-9]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return countries.firstWhere((country) => phoneNumber.substring(1).startsWith(country.dialCode + country.regionCode));
    }
    return countries.firstWhere((country) => phoneNumber.startsWith(country.dialCode + country.regionCode));
  }

  @override
  String toString() => 'PhoneNumber(isoCode: $isoCode, countryDialCode: $dialCode, number: $number)';
}
