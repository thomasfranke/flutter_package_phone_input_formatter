import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '/exports.dart';

class Parsers {
  String phoneParser(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);
    return phoneNumber.formatNsn();
  }

  bool phoneValidator(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);
    return phoneNumber.isValid();
  }

  String phoneIsoCode(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);

    inspect(phoneNumber.isoCode);
    log(convertIsoCountryCodeToDialCode(phoneNumber.isoCode.name));
    return phoneNumber.isoCode.name;
  }
}
