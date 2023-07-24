import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericFormField extends StatelessWidget {
  const NumericFormField({
    this.onFieldSubmitted,
    this.controller,
    super.key});

  final ValueChanged<String>? onFieldSubmitted;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[0-5]?\d')),
      ],
    );
  }
}
