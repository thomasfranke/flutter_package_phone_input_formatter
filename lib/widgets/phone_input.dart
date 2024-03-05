import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import '/exports.dart';

class PhoneInput extends StatefulWidget {
  final Key uniqueKey;
  final ValueChanged<PhoneNumberModel> onChanged;
  final ValueChanged<Country> onCountryChanged;
  final bool enabled;
  final String? initialValue;
  final String languageCode;
  final String initialCountryCode;
  final String? invalidNumberMessage;
  final Color cursorColor;
  final CountryPicker? countryPicker;
  final bool disableAutoFillHints;
  final String labelText;

  const PhoneInput({
    super.key,
    required this.initialCountryCode,
    required this.labelText,
    required this.onChanged,
    required this.onCountryChanged,
    required this.uniqueKey,
    this.countryPicker,
    this.cursorColor = Colors.white,
    this.disableAutoFillHints = false,
    this.enabled = true,
    this.initialValue,
    this.invalidNumberMessage = 'Invalid Mobile Number',
    this.languageCode = 'en',
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  late Country _selectedCountry;
  late String number;
  late bool validatedNumber;

  @override
  void initState() {
    super.initState();

    number = widget.initialValue ?? '';
    _selectedCountry = countries.firstWhere((item) => item.isoCode == (widget.initialCountryCode), orElse: () => countries.first);

    if (number.startsWith('+')) {
      number = number.replaceFirst(RegExp("^\\+${_selectedCountry.fullCountryCode}"), "");
    } else {
      number = number.replaceFirst(RegExp("^${_selectedCountry.fullCountryCode}"), "");
    }

    validatedNumber = PhoneNumberParser.phoneValidator(_selectedCountry.dialCode + number);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        key: widget.uniqueKey,
        initialValue: widget.initialValue ?? '',
        autofillHints: widget.disableAutoFillHints ? null : [AutofillHints.telephoneNumberNational],
        onChanged: (value) {
          final phoneNumber = PhoneNumberModel(isoCode: _selectedCountry.isoCode, dialCode: '+${_selectedCountry.fullCountryCode}', number: value);
          setState(() => validatedNumber = PhoneNumberParser.phoneValidator(phoneNumber.completeNumber));
          widget.onChanged.call(phoneNumber);
        },
        cursorColor: widget.cursorColor,
        enabled: widget.enabled,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: const TextStyle(color: Colors.white, fontSize: 14),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: const Color(0xffe9e9e9).withOpacity(0.1),
              width: 0.4,
            ),
          ),
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
    // filteredCountries = _countryList;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => CountryPickerDialog(
          languageCode: widget.languageCode.toLowerCase(),
          style: widget.countryPicker,
          filteredCountries: countries,
          searchText: "Search Country",
          countryList: countries,
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

  Widget _prefixFlagsButton() {
    // This updates thorugh block. Otherwise doens't update the Widget that actually changed the country.
    if (!widget.enabled) _selectedCountry = countries.firstWhere((item) => item.isoCode == (widget.initialCountryCode), orElse: () => countries.first);

    return Bounceable(
      onTap: widget.enabled ? _changeCountry : null,
      child: Container(
        margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.red.withOpacity(0.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            // if (widget.enabled && widget.showDropdownIcon && widget.dropdownIconPosition == IconPosition.leading) ...[Icon(Icons.arrow_drop_down, color: Colors.white), const SizedBox(width: 4)],
            Text(_selectedCountry.flag, style: const TextStyle(fontSize: 25)),
            const SizedBox(width: 8),
            FittedBox(child: Text('+${_selectedCountry.dialCode}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16))),
            // FittedBox(child: Text('+${_selectedCountry.dialCode}', style: widget.dropdownTextStyle)),
            // if (widget.enabled && widget.showDropdownIcon && widget.dropdownIconPosition == IconPosition.trailing) ...[
            // const SizedBox(width: 4),
            // widget.dropdownIcon, ],
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
