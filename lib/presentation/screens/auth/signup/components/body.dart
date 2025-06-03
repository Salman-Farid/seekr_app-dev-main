import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/components/rounded_button.dart';
import 'package:seekr_app/presentation/components/semi_rounded_email_field.dart';
import 'package:seekr_app/presentation/components/semi_rounded_password_field.dart';
import 'package:seekr_app/presentation/screens/auth/login/components/terms_and_conditions_dialog.dart';
import 'background.dart';
import 'package:seekr_app/application/settings_provider.dart';

class SignupBody extends HookConsumerWidget {
  const SignupBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final loading = useState(false);
    final loginKey = useMemoized(() => GlobalKey(debugLabel: 'loginKey'));

    final passwordKey = useMemoized(() => GlobalKey(debugLabel: 'passwordKey'));
    final passwordFocusNode = useFocusNode();
    final Size size = MediaQuery.of(context).size;
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
                    Expanded(
                      child: ExcludeSemantics(
                        child: Image.asset(
                          "assets/icons/seekrLogo.png",
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: ListView(
                        children: [
                          Semantics(
                            label: Words.of(context)!.yourEmail,
                            child: ExcludeSemantics(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus) {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                                child: SemiRoundedEmailField(
                                  hint: Words.of(context)!.emailPlaceHolder,
                                  emailController: emailController,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Semantics(
                            key: passwordKey,
                            label: Words.of(context)!.yourPassword,
                            child: SemiRoundedPasswordField(
                                passwordController: passwordController,
                                focusNode: passwordFocusNode,
                                onFieldSubmitted: (value) {
                                  loginKey.currentContext
                                      ?.findRenderObject()
                                      ?.sendSemanticsEvent(
                                          const FocusSemanticEvent());
                                },
                                enabled: !loading.value,
                                hideLabel:
                                    Words.of(context)!.buttonHidePassword,
                                showLabel:
                                    Words.of(context)!.buttonShowPassword,
                                text: Words.of(context)!.password),
                          ),
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: size.width / 2),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Semantics(
                                key: loginKey,
                                label: Words.of(context)!.signUpButton,
                                child: ExcludeSemantics(
                                  child: RoundedButton(
                                    text: Words.of(context)!.signUp,
                                    press: () async {
                                      loading.value = true;
                                      try {
                                        await FirebaseAuth.instance
                                            .createUserWithEmailAndPassword(
                                                email:
                                                    emailController.text.trim(),
                                                password: passwordController
                                                    .text
                                                    .trim());
                                      } on FirebaseAuthException catch (e) {
                                        Logger.i(e);

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(e.message!)));
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(e.toString())));
                                        }
                                      }
                                      loading.value = false;
                                    },
                                    color: const Color(0xff01A0C7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Semantics(
                                label:
                                    Words.of(context)!.signInWithGoogleButton,
                                child: ExcludeSemantics(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        final canDialog =
                                            await showDialog<bool>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) =>
                                              const TermsAndConditionsDialog(),
                                        );
                                        if (canDialog == true) {
                                          final googleUser =
                                              await GoogleSignIn().signIn();
                                          if (googleUser != null) {
                                            final googleAuth =
                                                await googleUser.authentication;

                                            final credential =
                                                GoogleAuthProvider.credential(
                                              accessToken:
                                                  googleAuth.accessToken,
                                              idToken: googleAuth.idToken,
                                            );

                                            await FirebaseAuth.instance
                                                .signInWithCredential(
                                                    credential);
                                            if (context.mounted) {
                                              CherryToast.success(
                                                description: const Text(
                                                  'User logged in successfully',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                animationType:
                                                    AnimationType.fromLeft,
                                              ).show(context);
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          CherryToast.error(
                                            description: Text(
                                              e.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            animationType:
                                                AnimationType.fromLeft,
                                          ).show(context);
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .grey[300], // Light gray background
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * .05,
                                        vertical: size.width * .03,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          "assets/images/google_logo.png",
                                          width: size.width * .07,
                                          height: size.width * .07,
                                        ),
                                        SizedBox(width: size.width * .03),
                                        Text(
                                          Words.of(context)!.signInWithGoogle,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * .13,
                              ),
                              Visibility(
                                visible: false,
                                child: GestureDetector(
                                  onTap: () {
                                    // FacebookSignInProvider().facebookLogin();
                                  },
                                  child: Image.asset(
                                    "assets/images/facebook_logo.png",
                                    width: size.width * .15,
                                    height: size.width * .15,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Semantics(
                                label: Words.of(context)!.signInWithAppleButton,
                                child: ExcludeSemantics(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        final canDialog =
                                            await showDialog<bool>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) =>
                                              const TermsAndConditionsDialog(),
                                        );
                                        if (canDialog == true) {
                                          final authProvider =
                                              AppleAuthProvider();
                                          await FirebaseAuth.instance
                                              .signInWithProvider(authProvider);
                                          if (context.mounted) {
                                            CherryToast.success(
                                              description: const Text(
                                                'User logged in successfully',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              animationType:
                                                  AnimationType.fromLeft,
                                            ).show(context);
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          CherryToast.error(
                                            description: Text(
                                              e.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            animationType:
                                                AnimationType.fromLeft,
                                          ).show(context);
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .grey[300], // Light gray background
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * .07,
                                        vertical: size.width * .03,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          "assets/images/apple_logo.png",
                                          width: size.width * .07,
                                          height: size.width * .07,
                                        ),
                                        SizedBox(width: size.width * .03),
                                        Text(
                                          Words.of(context)!.signInWithApple,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: size.width * .11,
                              // ),
                              Visibility(
                                visible: false,
                                child: GestureDetector(
                                  onTap: () {
                                    // FacebookSignInProvider().facebookLogin();
                                  },
                                  child: Image.asset(
                                    "assets/images/facebook_logo.png",
                                    width: size.width * .15,
                                    height: size.width * .15,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final textScale = ref
                                  .watch(settingsProvider)
                                  .requireValue
                                  .textScale;

                              return textScale > 1.3
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Words.of(context)!
                                              .alreadyHaveAccountText,
                                          style: TextStyle(
                                            fontFamily: 'NeueMachina-Regular',
                                            fontSize: size.width * .041,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            context.pop();
                                          },
                                          child: Semantics(
                                            label:
                                                Words.of(context)!.logInButton,
                                            child: ExcludeSemantics(
                                              child: Text(
                                                Words.of(context)!.logIn,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xff01A0C7),
                                                  fontFamily:
                                                      'Rounded_Elegance',
                                                  fontSize: size.width * .041,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Words.of(context)!
                                              .alreadyHaveAccountText,
                                          style: TextStyle(
                                            fontFamily: 'NeueMachina-Regular',
                                            fontSize: size.width * .041,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            context.pop();
                                          },
                                          child: Semantics(
                                            label:
                                                Words.of(context)!.logInButton,
                                            child: ExcludeSemantics(
                                              child: Text(
                                                Words.of(context)!.logIn,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xff01A0C7),
                                                  fontFamily:
                                                      'Rounded_Elegance',
                                                  fontSize: size.width * .041,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // Future signUp() async {
  //   if (emailController.text.isEmpty || passwordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(Words.of(context)!.emptyFieldEncounter)));

  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(child: CircularProgressIndicator()),
  //   );

  // try {
  //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim());
  // } on FirebaseAuthException catch (e) {
  //   Logger.i(e);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text(e.message!)));
  //   }
  //     return;
  //   }
  //   if (mounted) {
  //     context.go(CameraPage.routePath);
  //   }

  //   // navigatorKey.currentState!.popUntil((route) => route.isFirst);
  // }
}
