import 'package:flutter/material.dart';
import 'package:seekr_app/infrastructure/constants.dart';
import 'text_field_container.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const RoundedPasswordField({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: widget.controller,
        obscureText: obscure,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Password",
          icon: const Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: GestureDetector(
            onTap: toggle,
            child: const Icon(
              Icons.visibility,
              color: kPrimaryColor,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void toggle() => setState(() => obscure = !obscure);
}
