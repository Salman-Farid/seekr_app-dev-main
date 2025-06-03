import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:seekr_app/presentation/components/rounded_button.dart';
import 'package:seekr_app/presentation/components/semi_rounded_email_field.dart';

import 'background.dart';

class ForgotPasswordScreen extends HookWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final emailController = useTextEditingController();
    final loading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: size.height * .025,
                          top: size.height * .025,
                          bottom: size.height * .0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ᐸ  Back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Rounded_Elegance",
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * .045),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: EdgeInsets.only(
                        top: AppBar().preferredSize.height +
                            MediaQuery.of(context).padding.top,
                        left: size.width * .1,
                        right: size.width * .1),
                    child: Image.asset(
                      "assets/icons/seekrLogo.png",
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: size.width * .05),
                    child: Text("Receive an email to reset your password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'NeueMachina-Regular',
                            fontSize: size.width * .041)),
                  ),
                  // SizedBox(height: size.height * 0.10),
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * .15,
                    ),
                    child: SemiRoundedEmailField(
                      hint: "Your Email",
                      emailController: emailController,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.width * .05,
                        left: size.width * 0.2,
                        right: size.width * 0.2),
                    child: RoundedButton(
                      text: "RESET PASSWORD",
                      press: () async {
                        if (formKey.currentState!.validate() &&
                            !loading.value) {
                          try {
                            loading.value = true;
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: emailController.text.trim());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Password Reset Email Sent")));
                            }
                            // navigatorKey.currentState!.popUntil((route) => route.isFirst);
                          } on FirebaseAuthException catch (e) {
                            Logger.i(e);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message!)));
                            }
                          }
                          loading.value = false;
                        }
                      },
                      color: const Color(0xff01A0C7),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.width * .055),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive email? ',
                            style: TextStyle(
                              fontFamily: 'NeueMachina-Regular',
                              fontSize: size.width * .041,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (formKey.currentState!.validate() &&
                                  !loading.value) {
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                          email: emailController.text.trim());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Password Reset Email Sent")));
                                  }
                                } on FirebaseAuthException catch (e) {
                                  Logger.i(e);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.message!)));
                                  }
                                }
                                loading.value = false;
                              }
                            },
                            child: Text(
                              'Resend Email',
                              style: TextStyle(
                                color: const Color(0xff01A0C7),
                                fontFamily: 'Rounded_Elegance',
                                fontSize: size.width * .041,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
