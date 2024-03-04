import 'package:flutter/material.dart';
import '/exports.dart';

class PhoneInput extends StatefulWidget {
  final ValueChanged<PhoneNumberModel> onChanged;
  final ValueChanged<Country> onCountryChanged;
  final bool enabled;
  final String? initialValue;
  final String languageCode;
  final String initialCountryCode;
  final List<Country>? countries;
  final String? invalidNumberMessage;
  final Color cursorColor;
  final CountryPicker? countryPicker;
  final bool disableAutoFillHints;

  const PhoneInput({
    super.key,
    required this.initialCountryCode,
    this.languageCode = 'en',
    this.disableAutoFillHints = false,
    this.initialValue,
    required this.onChanged,
    this.countries,
    required this.onCountryChanged,
    this.enabled = true,
    this.cursorColor = Colors.white,
    this.invalidNumberMessage = 'Invalid Mobile Number',
    this.countryPicker,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  late List<Country> _countryList;
  late Country _selectedCountry;
  late List<Country> filteredCountries;
  late String number;
  late bool validatedNumber;

  @override
  void initState() {
    super.initState();
    _countryList = widget.countries ?? countries;
    filteredCountries = _countryList;
    number = widget.initialValue ?? '';
    // if (widget.initialCountryCode == null && number.startsWith('+')) {
    //   number = number.substring(1);
    //   _selectedCountry = countries.firstWhere((country) => number.startsWith(country.fullCountryCode), orElse: () => _countryList.first);

    //   // remove country code from the initial number value
    //   number = number.replaceFirst(RegExp("^${_selectedCountry.fullCountryCode}"), "");
    // } else {
    log('procurando ${widget.initialCountryCode}');
    _selectedCountry = _countryList.firstWhere((item) {
      return item.codeIso == (widget.initialCountryCode);
    }, orElse: () => _countryList.first);

    log('encontrou ${_selectedCountry.name}');
    // remove country code from the initial number value
    // if (number.startsWith('+')) {
    // number = number.replaceFirst(RegExp("^\\+${_selectedCountry.fullCountryCode}"), "");
    // } else {
    // number = number.replaceFirst(RegExp("^${_selectedCountry.fullCountryCode}"), "");
    // }
    // }
    validatedNumber = PhoneNumberParser.phoneValidator(_selectedCountry.dialCode + number);
    // validatedNumber = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        initialValue: number,
        autofillHints: widget.disableAutoFillHints ? null : [AutofillHints.telephoneNumberNational],
        onChanged: (value) {
          final phoneNumber = PhoneNumberModel(countryISOCode: _selectedCountry.codeIso, countryCode: '+${_selectedCountry.fullCountryCode}', number: value);
          // String displayNumber = PhoneNumberParser.phoneParser(phoneNumber.completeNumber);
          setState(() => validatedNumber = PhoneNumberParser.phoneValidator(phoneNumber.completeNumber));
          widget.onChanged.call(phoneNumber);
        },
        cursorColor: widget.cursorColor,
        enabled: widget.enabled,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: validatedNumber ? Colors.green : Colors.red, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: validatedNumber ? Colors.green : Colors.red, width: 2.0),
          ),
          prefixIcon: _prefixFlagsButton(),
          counterText: !widget.enabled ? '' : null,
        ),
      ),
    );
  }

  Future<void> _changeCountry() async {
    filteredCountries = _countryList;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => CountryPickerDialog(
          languageCode: widget.languageCode.toLowerCase(),
          style: widget.countryPicker,
          filteredCountries: filteredCountries,
          searchText: "Search Country",
          countryList: _countryList,
          selectedCountry: _selectedCountry,
          onCountryChanged: (Country country) {
            _selectedCountry = country;
            widget.onCountryChanged.call(country);
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Container _prefixFlagsButton() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: InkWell(
          onTap: widget.enabled ? _changeCountry : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              // if (widget.enabled && widget.showDropdownIcon && widget.dropdownIconPosition == IconPosition.leading) ...[Icon(Icons.arrow_drop_down, color: Colors.white), const SizedBox(width: 4)],

              Text(_selectedCountry.flag, style: const TextStyle(fontSize: 25)),
              const SizedBox(width: 8),

              // FittedBox(child: Text('+${_selectedCountry.dialCode}', style: widget.dropdownTextStyle)),
              // if (widget.enabled && widget.showDropdownIcon && widget.dropdownIconPosition == IconPosition.trailing) ...[
              // const SizedBox(width: 4),
              // widget.dropdownIcon,
              // ],
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
