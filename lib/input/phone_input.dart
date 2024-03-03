import 'dart:async';
import 'package:flutter/material.dart';

import '/exports.dart';

class PhoneInput extends StatefulWidget {
  final ValueChanged<PhoneNumber>? onChanged;
  final ValueChanged<Country>? onCountryChanged;
  final bool enabled;
  final String? initialValue;
  final String languageCode;
  final String? initialCountryCode;
  final List<Country>? countries;
  final InputDecoration decoration;
  final TextStyle? style;
  final bool showDropdownIcon;
  final BoxDecoration dropdownDecoration;
  final TextStyle? dropdownTextStyle;
  final IconPosition dropdownIconPosition;
  final Icon dropdownIcon;
  final bool showCountryFlag;
  final String? invalidNumberMessage;
  final Color cursorColor;
  final EdgeInsetsGeometry flagsButtonPadding;
  final CountryPicker? countryPicker;
  final EdgeInsets flagsButtonMargin;
  final bool disableAutoFillHints;

  const PhoneInput({
    super.key,
    this.initialCountryCode,
    this.languageCode = 'en',
    this.disableAutoFillHints = false,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.style,
    this.dropdownTextStyle,
    this.onChanged,
    this.countries,
    this.onCountryChanged,
    this.showDropdownIcon = true,
    this.dropdownDecoration = const BoxDecoration(),
    this.enabled = true,
    this.dropdownIconPosition = IconPosition.leading,
    this.dropdownIcon = const Icon(Icons.arrow_drop_down, color: Colors.white),
    this.showCountryFlag = true,
    this.cursorColor = Colors.white,
    this.flagsButtonPadding = EdgeInsets.zero,
    this.invalidNumberMessage = 'Invalid Mobile Number',
    this.countryPicker,
    this.flagsButtonMargin = EdgeInsets.zero,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  late List<Country> _countryList;
  late Country _selectedCountry;
  late List<Country> filteredCountries;
  late String number;
  bool validatedNumber = false;

  @override
  void initState() {
    super.initState();
    _countryList = widget.countries ?? countries;
    filteredCountries = _countryList;
    number = widget.initialValue ?? '';
    if (widget.initialCountryCode == null && number.startsWith('+')) {
      number = number.substring(1);
      // parse initial value
      _selectedCountry = countries.firstWhere((country) => number.startsWith(country.fullCountryCode), orElse: () => _countryList.first);

      // remove country code from the initial number value
      number = number.replaceFirst(RegExp("^${_selectedCountry.fullCountryCode}"), "");
    } else {
      _selectedCountry = _countryList.firstWhere((item) => item.code == (widget.initialCountryCode ?? 'US'), orElse: () => _countryList.first);

      // remove country code from the initial number value
      if (number.startsWith('+')) {
        number = number.replaceFirst(RegExp("^\\+${_selectedCountry.fullCountryCode}"), "");
      } else {
        number = number.replaceFirst(RegExp("^${_selectedCountry.fullCountryCode}"), "");
      }
    }
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
            widget.onCountryChanged?.call(country);
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofillHints: widget.disableAutoFillHints ? null : [AutofillHints.telephoneNumberNational],
      cursorColor: widget.cursorColor,
      enabled: widget.enabled,
      initialValue: number,
      keyboardType: TextInputType.phone,
      style: widget.style,
      onChanged: (value) {
        final phoneNumber = PhoneNumber(countryISOCode: _selectedCountry.code, countryCode: '+${_selectedCountry.fullCountryCode}', number: value);
        setState(() => validatedNumber = Parsers().phoneValidator(phoneNumber.completeNumber));
        log(Parsers().phoneParser(phoneNumber.completeNumber));
        widget.onChanged?.call(phoneNumber);
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: validatedNumber ? Colors.green : Colors.redAccent, width: 3.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: validatedNumber ? Colors.green : Colors.redAccent, width: 3.0),
        ),
        prefixIcon: _prefixFlagsButton(),
        counterText: !widget.enabled ? '' : null,
      ),
    );
  }

  Container _prefixFlagsButton() {
    return Container(
      margin: widget.flagsButtonMargin,
      child: DecoratedBox(
        decoration: widget.dropdownDecoration,
        child: InkWell(
          borderRadius: widget.dropdownDecoration.borderRadius as BorderRadius?,
          onTap: widget.enabled ? _changeCountry : null,
          child: Padding(
            padding: widget.flagsButtonPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                if (widget.enabled && widget.showDropdownIcon && widget.dropdownIconPosition == IconPosition.leading) ...[
                  widget.dropdownIcon,
                  const SizedBox(width: 4)
                ],
                if (widget.showCountryFlag) ...[
                  Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ],
                FittedBox(child: Text('+${_selectedCountry.dialCode}', style: widget.dropdownTextStyle)),
                if (widget.enabled && widget.showDropdownIcon && widget.dropdownIconPosition == IconPosition.trailing) ...[
                  const SizedBox(width: 4),
                  widget.dropdownIcon,
                ],
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum IconPosition {
  leading,
  trailing,
}
