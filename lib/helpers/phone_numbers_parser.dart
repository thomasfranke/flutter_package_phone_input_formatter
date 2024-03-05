import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '/exports.dart';

class PhoneNumberParser {
  static String phoneParser(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);
    return phoneNumber.formatNsn();
  }

  static bool phoneValidator(String phone) {
    log('validating phone: $phone');
    final phoneNumber = PhoneNumber.parse(phone);
    return phoneNumber.isValid();
  }

  static String phoneIsoCode(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);

    // inspect(phoneNumber.isoCode);

    // log("phoneIsoCode: ${phoneNumber.isoCode.name}");
    return phoneNumber.isoCode.name;
  }

  static String phoneDialCode(String phone) {
    final phoneNumber = PhoneNumber.parse(phone);

    // inspect(phoneNumber.isoCode);
    // log(convertIsoCountryCodeToDialCode(phoneNumber.isoCode.name));
    // log("phoneDialCode: " + phoneNumber.nsn.);
    // log("phoneDialCode: ${convertIsoCountryCodeToDialCode(phoneNumber.isoCode.name)}");
    return convertIsoCountryCodeToDialCode(phoneNumber.isoCode.name);
  }
}
