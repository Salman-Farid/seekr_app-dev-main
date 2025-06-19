import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/shared_pref_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/auth/login/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:seekr_app/presentation/screens/settings/widgets/instructions_button.dart';
import 'package:seekr_app/presentation/screens/settings/widgets/settings_buttons.dart';
import 'widgets/about_seekr.dart';

class SettingsPage extends ConsumerStatefulWidget {
  static const routeName = 'settings';
  static const routePath = '/settings';
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool showExitDialog = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (v, _) {
        setState(() {
          showExitDialog = true;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 5,
          title: ExcludeSemantics(
            child: Center(
              child: Text(
                Words.of(context)!.appSettings,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Rounded_Elegance',
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF9F8FD),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20.0),
                      children: <Widget>[
                        const SettingsButtons(),
                        // ElevatedButton(
                        //     onPressed: () async {
                        //       context.push(PackagePlansSheet.routePath);
                        //       // final x = await ref
                        //       //     .read(subscriptionRepoProvider)
                        //       //     .getSubscriptionPlans();
                        //       // Logger.i(x);
                        //     },
                        //     child: const Text('Subscription button')),
                        Semantics(
                          label: Words.of(context)!.logOut,
                          button: true,
                          child: ElevatedButton(
                            onPressed: () async {
                              Logger.i('Logging out');
                              try {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().disconnect();
                              } catch (e) {
                                Logger.i(e);
                              }

                              if (context.mounted) {
                                context.go(LoginScreen.routePath);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFFD702),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                            ),
                            child: Text(Words.of(context)!.logOut,
                                style: TextStyle(
                                    fontSize: size.width * .033,
                                    color: Colors.black,
                                    fontFamily: 'Rounded_Elegance',
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                            label: Words.of(context)!.buttonToKnowUsage,
                            child: const InstructionsButton()),
                        SizedBox(
                            height: MediaQuery.of(context).size.width * .021),
                        const AboutSeekr(),
                        TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                        title:
                                            Text(Words.of(context)!.areYouSure),
                                        content: Text(Words.of(context)!
                                            .deleteDescription),
                                        actions: [
                                          CupertinoDialogAction(
                                              isDestructiveAction: true,
                                              onPressed: () {
                                                context.pop(true);
                                              },
                                              child:
                                                  Text(Words.of(context)!.yes)),
                                          TextButton(
                                            child: Text(Words.of(context)!.no),
                                            onPressed: () {
                                              context.pop(false);
                                            },
                                          ),
                                        ],
                                      ));

                              if (shouldDelete == true) {
                                try {
                                  Logger.i('Deleting account');

                                  await FirebaseAuth.instance.currentUser
                                      ?.delete();
                                  await ref
                                      .read(sharedPreferecesProvider)
                                      .requireValue
                                      .remove('skipped_location_permission');
                                } on FirebaseAuthException catch (error) {
                                  if (context.mounted) {
                                    final msg = error.message ?? '';
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        msg,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                }
                              }
                            },
                            child: Text(Words.of(context)!.deleteAccount)),
                      ],
                    ),
                  ),
                ],
              ),
              Center(
                child: Visibility(
                  visible: showExitDialog,
                  child: Center(
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21)),
                      title: Text(
                        'Seekr',
                        style: TextStyle(
                          fontFamily: "Rounded_Elegance",
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * .055,
                        ),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          Words.of(context)!.wantToExitLabel,
                          style: const TextStyle(
                            fontFamily: "Rounded_Elegance",
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 11.0),
                          child: GestureDetector(
                            onTap: () {
                              exit(0);
                            },
                            child: Text(
                              Words.of(context)!.yes,
                              style: TextStyle(
                                  fontFamily: 'Rounded_Elegance',
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * .045,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 11.0, left: 11),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showExitDialog = false;
                              });
                            },
                            child: Text(
                              Words.of(context)!.no,
                              style: TextStyle(
                                  fontFamily: 'Rounded_Elegance',
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * .045,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
