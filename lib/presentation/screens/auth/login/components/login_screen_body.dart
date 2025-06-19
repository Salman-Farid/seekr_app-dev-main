import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/auth/login/components/terms_and_conditions_dialog.dart';
import 'package:seekr_app/presentation/screens/auth/signup/signup_screen.dart';
import 'package:seekr_app/presentation/components/rounded_button.dart';
import 'package:seekr_app/presentation/components/semi_rounded_email_field.dart';
import 'package:seekr_app/presentation/components/semi_rounded_password_field.dart';
import 'package:seekr_app/presentation/screens/auth/forgot_password/forgot_password_screen.dart';
import 'background.dart';
import 'or_divider.dart';
import 'package:seekr_app/application/settings_provider.dart';

class LoginScreenBody extends HookConsumerWidget {
  const LoginScreenBody({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final loading = useState(false);
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ExcludeSemantics(child: Expanded(flex: 1, child: SizedBox())),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * .1),
              child: ExcludeSemantics(
                child: Image.asset(
                  'assets/icons/seekrLogo.png',
                ),
              ),
            ),
          ),
          Expanded(
            flex: 20,
            child: ListView(
              children: [
                Form(
                  key: formKey,
                  child: Semantics(
                    explicitChildNodes: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Semantics(
                              label: Words.of(context)!.yourEmail,
                              child: ExcludeSemantics(
                                child: SemiRoundedEmailField(
                                  emailController: emailController,
                                  enabled: !loading.value,
                                  hint: Words.of(context)!.emailPlaceHolder,
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Semantics(
                            label: Words.of(context)!.yourPassword,
                            textField: false,
                            child: ExcludeSemantics(
                              child: SemiRoundedPasswordField(
                                  enabled: !loading.value,
                                  hideLabel:
                                      Words.of(context)!.buttonHidePassword,
                                  showLabel:
                                      Words.of(context)!.buttonShowPassword,
                                  passwordController: passwordController,
                                  text: Words.of(context)!.password),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Padding(
                            padding: EdgeInsets.only(right: size.width * .15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) =>
                                            const ForgotPasswordScreen()));
                              },
                              child: Semantics(
                                label: Words.of(context)!.forgotPasswordButton,
                                child: ExcludeSemantics(
                                  child: Text(
                                    Words.of(context)!.forgotPassword,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontFamily: "NeueMachina-Regular",
                                        // fontWeight: FontWeight.bold,
                                        fontSize: size.width * .041,
                                        color: const Color(0xff092E49)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: size.width * .05,
                      left: size.width * 0.2,
                      right: size.width * 0.2),
                  child: Semantics(
                    label: Words.of(context)!.logInButton,
                    child: ExcludeSemantics(
                      child: RoundedButton(
                        loading: loading.value,
                        text: Words.of(context)!.logIn,
                        press: () async {
                          if (!loading.value) {
                            try {
                              if (formKey.currentState!.validate()) {
                                final canDialog = await showDialog<bool>(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) =>
                                      const TermsAndConditionsDialog(),
                                );
                                if (canDialog == true) {
                                  loading.value = true;
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim());
                                }
                              }
                            } on FirebaseAuthException catch (e) {
                              Logger.i(e);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.message!)));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                            }
                            if (context.mounted) {
                              loading.value = false;
                            }
                          }
                        },
                        color: const Color(0xff01A0C7),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: size.width * .025,
                        left: size.width * 0.2,
                        right: size.width * 0.2),
                    child: RoundedButton(
                      text: Words.of(context)!.skip,
                      press: () async {
                        final canDialog = await showDialog<bool>(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) =>
                              const TermsAndConditionsDialog(),
                        );
                        if (canDialog == true) {
                          FirebaseAuth.instance.signInAnonymously();
                        }
                      },
                      color: Colors.black54,
                    ),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: size.width * .085),
                    child: ExcludeSemantics(
                        child: OrDivider(Words.of(context)!.or)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Semantics(
                      label: Words.of(context)!.signInWithGoogleButton,
                      child: ExcludeSemantics(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final canDialog = await showDialog<bool>(
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
                                    accessToken: googleAuth.accessToken,
                                    idToken: googleAuth.idToken,
                                  );

                                  await FirebaseAuth.instance
                                      .signInWithCredential(credential);
                                  if (context.mounted) {
                                    CherryToast.success(
                                      description: const Text(
                                        'User logged in successfully',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      animationType: AnimationType.fromLeft,
                                    ).show(context);
                                  }
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CherryToast.error(
                                  description: Text(
                                    e.toString(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  animationType: AnimationType.fromLeft,
                                ).show(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey[300], // Light gray background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
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
                              final canDialog = await showDialog<bool>(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) =>
                                    const TermsAndConditionsDialog(),
                              );
                              if (canDialog == true) {
                                final authProvider = AppleAuthProvider();
                                await FirebaseAuth.instance
                                    .signInWithProvider(authProvider);
                                if (context.mounted) {
                                  CherryToast.success(
                                    description: const Text(
                                      'User logged in successfully',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    animationType: AnimationType.fromLeft,
                                  ).show(context);
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CherryToast.error(
                                  description: Text(
                                    e.toString(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  animationType: AnimationType.fromLeft,
                                ).show(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey[300], // Light gray background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.width * .055),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Dynamically determine if the text should stack vertically based on available width
                      final textScale =
                          ref.watch(settingsProvider).requireValue.textScale;
                      // bool shouldStack = textScale > 1.3;

                      // if (textScale <= 1.3){
                      //   shouldStack = false;
                      // }else{
                      //    shouldStack = true;
                      // }

                      Logger.i(
                          'constraints________maxWidth ${constraints.maxWidth}');
                      Logger.i('size___________width ${size.width}');

                      return textScale > 1.3
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Words.of(context)!.signUpText,
                                  style: TextStyle(
                                    fontFamily: 'NeueMachina-Regular',
                                    fontSize: size.width * .041,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => const SignUpScreen()),
                                    );
                                  },
                                  child: Semantics(
                                    label: Words.of(context)!.signUpButton,
                                    child: ExcludeSemantics(
                                      child: Text(
                                        Words.of(context)!.signUp,
                                        style: TextStyle(
                                          color: const Color(0xff01A0C7),
                                          fontFamily: 'Rounded_Elegance',
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Words.of(context)!.signUpText,
                                  style: TextStyle(
                                    fontFamily: 'NeueMachina-Regular',
                                    fontSize: size.width * .041,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => const SignUpScreen()),
                                    );
                                  },
                                  child: Semantics(
                                    label: Words.of(context)!.signUpButton,
                                    child: ExcludeSemantics(
                                      child: Text(
                                        Words.of(context)!.signUp,
                                        style: TextStyle(
                                          color: const Color(0xff01A0C7),
                                          fontFamily: 'Rounded_Elegance',
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
                ),
              ],
            ),
          ),
          Visibility(
              visible: loading.value, child: const LinearProgressIndicator()),
        ],
      ),
    );
  }
}
