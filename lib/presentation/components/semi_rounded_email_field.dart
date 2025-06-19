import 'package:flutter/material.dart';

class SemiRoundedEmailField extends StatelessWidget {
  final TextEditingController emailController;
  final String hint;
  final bool enabled;

  const SemiRoundedEmailField(
      {super.key,
      required this.emailController,
      required this.hint,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
