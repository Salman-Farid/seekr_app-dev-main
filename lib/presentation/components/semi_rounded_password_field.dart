import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SemiRoundedPasswordField extends HookConsumerWidget {
  final TextEditingController passwordController;
  final String text, showLabel, hideLabel;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const SemiRoundedPasswordField(
      {super.key,
      required this.passwordController,
      required this.text,
      required this.showLabel,
      required this.hideLabel,
      this.focusNode,
      this.onFieldSubmitted,
      this.enabled = true});

  @override
  Widget build(BuildContext context, ref) {
    final size = MediaQuery.of(context).size;
    final obscureText = useState(false);
    return TextFormField(
      focusNode: focusNode,
      enabled: enabled,
      validator: (value) {
        Pattern pattern =
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d!@#$%^&*(),.?":{}|<>]{8,}$';
        RegExp regex = RegExp(pattern as String);
        if (!regex.hasMatch(value!)) {
          return 'Enter a valid password (At least 8 characters, one uppercase letter, one lowercase letter and one number)';
        } else {
          return null;
        }
      },
      onFieldSubmitted: onFieldSubmitted,
      controller: passwordController,
      obscureText: obscureText.value,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: const TextStyle(
            fontFamily: 'Rounded_Elegance', fontWeight: FontWeight.bold),
        prefixIcon: const ExcludeSemantics(child: Icon(Icons.lock)),
        suffixIcon: GestureDetector(
          onTap: () {
            obscureText.value = !obscureText.value;
          },
          child: Semantics(
            label: obscureText.value ? showLabel : hideLabel,
            child: SizedBox(
              width: size.width * .1,
              child: Icon(
                obscureText.value ? Icons.visibility_off : Icons.visibility,
                size: size.width * .055,
                weight: 1,
              ),
            ),
          ),
        ),
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
