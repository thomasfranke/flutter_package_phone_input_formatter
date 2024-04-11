import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '/exports.dart';

class PhoneNumberParser {
  static String phoneParser(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);
    return phoneNumber.formatNsn();
  }

  static bool phoneValidator(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);
    return phoneNumber.isValid();
  }

  static String phoneIsoCode(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);
    return phoneNumber.isoCode.name;
  }

  static String phoneDialCode(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);
    return convertIsoCountryCodeToDialCode(phoneNumber.isoCode.name);
  }
}
