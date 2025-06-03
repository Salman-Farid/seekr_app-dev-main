import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/components/rounded_button.dart';
import 'background.dart';
import 'package:seekr_app/presentation/screens/auth/login/login_screen.dart';
import 'package:seekr_app/presentation/screens/auth/signup/signup_screen.dart';

class SelectionBody extends HookConsumerWidget {
  const SelectionBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final loading = useState(false);

    Size size = MediaQuery.of(context).size;
    return Background(
      child: loading.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/icons/seekrLogo.png",
                    ),
                    SizedBox(height: size.height * 0.03),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: size.width / 2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Semantics(
                          label: Words.of(context)!.logInButton,
                          child: ExcludeSemantics(
                            child: RoundedButton(
                              text: Words.of(context)!.logIn,
                              press: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => const LoginScreen()));
                              },
                              color: const Color(0xff01A0C7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: size.width / 2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Semantics(
                          label: Words.of(context)!.signUpButton,
                          child: ExcludeSemantics(
                            child: RoundedButton(
                              text: Words.of(context)!.signUp,
                              press: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => const SignUpScreen()));
                              },
                              color: const Color(0xff01A0C7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
