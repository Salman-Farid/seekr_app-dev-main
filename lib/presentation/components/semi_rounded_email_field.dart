import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SemiRoundedEmailField extends HookWidget {
  final TextEditingController emailController;
  final String hint;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const SemiRoundedEmailField(
      {super.key,
      required this.emailController,
      required this.hint,
      this.focusNode,
      this.onFieldSubmitted,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      enabled: enabled,
      validator: (value) {
        Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
        RegExp regex = RegExp(pattern as String);
        if (!regex.hasMatch(value!)) {
          return 'Enter a valid email address';
        } else {
          return null;
        }
      },
      onFieldSubmitted: onFieldSubmitted,
      controller: emailController,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Rounded_Elegance', fontWeight: FontWeight.bold),
        prefixIcon: const Icon(Icons.person_3),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
