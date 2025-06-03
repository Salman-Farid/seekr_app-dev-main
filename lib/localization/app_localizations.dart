import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('tl'),
    Locale('zh'),
    Locale.fromSubtags(
        languageCode: 'zh', countryCode: 'CN', scriptCode: 'Hans'),
    Locale.fromSubtags(
        languageCode: 'zh', countryCode: 'HK', scriptCode: 'Hant')
  ];

  /// No description provided for @autoRead.
  ///
  /// In en, this message translates to:
  /// **'Auto Read'**
  String get autoRead;

  /// No description provided for @autoReadButton.
  ///
  /// In en, this message translates to:
  /// **'Auto Read, button'**
  String get autoReadButton;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @batteryStatus.
  ///
  /// In en, this message translates to:
  /// **'Battery Status'**
  String get batteryStatus;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @voiceSpeed.
  ///
  /// In en, this message translates to:
  /// **'Voice Speed'**
  String get voiceSpeed;

  /// No description provided for @voicePitch.
  ///
  /// In en, this message translates to:
  /// **'Voice Pitch'**
  String get voicePitch;

  /// No description provided for @voiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Voice Language'**
  String get voiceLanguage;

  /// No description provided for @displayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display Language'**
  String get displayLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @noText.
  ///
  /// In en, this message translates to:
  /// **'No Text Detected!'**
  String get noText;

  /// No description provided for @noTextMsg.
  ///
  /// In en, this message translates to:
  /// **'Take another picture'**
  String get noTextMsg;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @detectedText.
  ///
  /// In en, this message translates to:
  /// **'Detected Text'**
  String get detectedText;

  /// No description provided for @textButton.
  ///
  /// In en, this message translates to:
  /// **'Text \nRecognition'**
  String get textButton;

  /// No description provided for @objectButton.
  ///
  /// In en, this message translates to:
  /// **'Object \nDetection'**
  String get objectButton;

  /// No description provided for @depthButton.
  ///
  /// In en, this message translates to:
  /// **'Depth \nEstimation'**
  String get depthButton;

  /// No description provided for @textButtonDevice.
  ///
  /// In en, this message translates to:
  /// **'Mode switched to text detection.'**
  String get textButtonDevice;

  /// No description provided for @objectButtonDevice.
  ///
  /// In en, this message translates to:
  /// **'Object Detection'**
  String get objectButtonDevice;

  /// No description provided for @depthButtonDevice.
  ///
  /// In en, this message translates to:
  /// **'Mode switched to depth detection.'**
  String get depthButtonDevice;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How To Use'**
  String get howToUse;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More Info'**
  String get moreInfo;

  /// No description provided for @remainingTries.
  ///
  /// In en, this message translates to:
  /// **'Remaining tries'**
  String get remainingTries;

  /// No description provided for @detectedObjects.
  ///
  /// In en, this message translates to:
  /// **'Detected Objects'**
  String get detectedObjects;

  /// No description provided for @detectedDepth.
  ///
  /// In en, this message translates to:
  /// **'Detected Depth'**
  String get detectedDepth;

  /// No description provided for @connectToDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect to Device'**
  String get connectToDevice;

  /// No description provided for @enableWifi.
  ///
  /// In en, this message translates to:
  /// **'Enable WiFi'**
  String get enableWifi;

  /// No description provided for @connectDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect Device'**
  String get connectDevice;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Denied'**
  String get locationPermissionDenied;

  /// No description provided for @grantLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Location Permission'**
  String get grantLocationPermission;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get logIn;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'email, text field, double tap to edit'**
  String get yourEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @signUpText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get signUpText;

  /// No description provided for @alreadyHaveAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountText;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @noObjectDetected.
  ///
  /// In en, this message translates to:
  /// **'No Objects Detected!'**
  String get noObjectDetected;

  /// No description provided for @enabledTalkback.
  ///
  /// In en, this message translates to:
  /// **'Talkback is enabled, keep swiping to hear the text.'**
  String get enabledTalkback;

  /// No description provided for @disabledTalkback.
  ///
  /// In en, this message translates to:
  /// **'Talkback is disabled, use the buttons to play the audio.'**
  String get disabledTalkback;

  /// No description provided for @enabledVoiceover.
  ///
  /// In en, this message translates to:
  /// **'VoiceOver is enabled, keep swiping to hear the text.'**
  String get enabledVoiceover;

  /// No description provided for @disabledVoiceover.
  ///
  /// In en, this message translates to:
  /// **'VoiceOver is disabled, use the buttons to play the audio.'**
  String get disabledVoiceover;

  /// No description provided for @deviceViewfinder.
  ///
  /// In en, this message translates to:
  /// **'Device Viewfinder.'**
  String get deviceViewfinder;

  /// No description provided for @disconnectFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Disconnect from Device.'**
  String get disconnectFromDevice;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @selectSeekrDevice.
  ///
  /// In en, this message translates to:
  /// **'Select Seekr Device'**
  String get selectSeekrDevice;

  /// No description provided for @turnOnWifiLocation.
  ///
  /// In en, this message translates to:
  /// **'Please turn on WiFi and location'**
  String get turnOnWifiLocation;

  /// No description provided for @runOutOfTry.
  ///
  /// In en, this message translates to:
  /// **'You have ran out of tries!'**
  String get runOutOfTry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cameraPage.
  ///
  /// In en, this message translates to:
  /// **'Camera Page'**
  String get cameraPage;

  /// No description provided for @devicePage.
  ///
  /// In en, this message translates to:
  /// **'Device Page'**
  String get devicePage;

  /// No description provided for @settingPage.
  ///
  /// In en, this message translates to:
  /// **'Setting Page'**
  String get settingPage;

  /// No description provided for @noTextDetected.
  ///
  /// In en, this message translates to:
  /// **'No Detected Text'**
  String get noTextDetected;

  /// No description provided for @pressHereToConnect.
  ///
  /// In en, this message translates to:
  /// **'Press here to connect to Device in Settings'**
  String get pressHereToConnect;

  /// No description provided for @connectToSeekrWifi.
  ///
  /// In en, this message translates to:
  /// **'Please connect to Seekr WIFI'**
  String get connectToSeekrWifi;

  /// No description provided for @processSound.
  ///
  /// In en, this message translates to:
  /// **'Processing Sound'**
  String get processSound;

  /// No description provided for @errorConnect.
  ///
  /// In en, this message translates to:
  /// **'An error has occured while connecting, please try again'**
  String get errorConnect;

  /// No description provided for @errorDownload.
  ///
  /// In en, this message translates to:
  /// **'An error has occured while downloading, please try again'**
  String get errorDownload;

  /// No description provided for @errorTakingPic.
  ///
  /// In en, this message translates to:
  /// **'An error has occured while taking a picture, please try again'**
  String get errorTakingPic;

  /// No description provided for @errorOccured.
  ///
  /// In en, this message translates to:
  /// **'Error occured'**
  String get errorOccured;

  /// No description provided for @noCameraDetected.
  ///
  /// In en, this message translates to:
  /// **'No Camera Detected'**
  String get noCameraDetected;

  /// No description provided for @semanticTextDetectionButton.
  ///
  /// In en, this message translates to:
  /// **'Reading, button'**
  String get semanticTextDetectionButton;

  /// No description provided for @semanticDepthDetectionButton.
  ///
  /// In en, this message translates to:
  /// **'Distance, button'**
  String get semanticDepthDetectionButton;

  /// No description provided for @semanticSceneDetectionButton.
  ///
  /// In en, this message translates to:
  /// **'Scene, button'**
  String get semanticSceneDetectionButton;

  /// No description provided for @semanticSupermarketButton.
  ///
  /// In en, this message translates to:
  /// **'Supermarket, Button'**
  String get semanticSupermarketButton;

  /// No description provided for @semanticBusButton.
  ///
  /// In en, this message translates to:
  /// **'Bus Detection Button'**
  String get semanticBusButton;

  /// No description provided for @semanticWalkingButton.
  ///
  /// In en, this message translates to:
  /// **'Walking Mode Button'**
  String get semanticWalkingButton;

  /// No description provided for @cameraButton.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraButton;

  /// No description provided for @deviceButton.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceButton;

  /// No description provided for @settingButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingButton;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get signInWithGoogle;

  /// No description provided for @termsAndCondition.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndCondition;

  /// No description provided for @termsAndConditionText.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right, at our sole discretion, to change, modify or otherwise alter these Terms and Conditions at any time. Unless otherwise indicated, amendments will become effective immediately. Please review these Terms and Conditions periodically. Your continued use of the Site following the posting of changes and/or modifications will constitute your acceptance of the revised Terms and Conditions and the reasonableness of these standards for notice of changes. For your information, this page was last updated as of the date at the top of these terms and conditions.'**
  String get termsAndConditionText;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get agree;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @buttonHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password, button'**
  String get buttonHidePassword;

  /// No description provided for @buttonShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password, button'**
  String get buttonShowPassword;

  /// No description provided for @emailPlaceHolder.
  ///
  /// In en, this message translates to:
  /// **'email...'**
  String get emailPlaceHolder;

  /// No description provided for @passwordPlaceHolder.
  ///
  /// In en, this message translates to:
  /// **'password...'**
  String get passwordPlaceHolder;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'sign up button'**
  String get signUpButton;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Login Button'**
  String get logInButton;

  /// No description provided for @emptyFieldEncounter.
  ///
  /// In en, this message translates to:
  /// **'Empty field(s) encountered!'**
  String get emptyFieldEncounter;

  /// No description provided for @recognizingSceneLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognizing scene from the picture...'**
  String get recognizingSceneLabel;

  /// No description provided for @extractingTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Extracting text(s) from the picture...'**
  String get extractingTextLabel;

  /// No description provided for @detectingObjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Detecting object(s) from the picture...'**
  String get detectingObjectLabel;

  /// No description provided for @detectingBusLabel.
  ///
  /// In en, this message translates to:
  /// **'Detecting bus information from the picture...'**
  String get detectingBusLabel;

  /// No description provided for @mappingDepthLabel.
  ///
  /// In en, this message translates to:
  /// **'Mapping depth of object(s) from the picture...'**
  String get mappingDepthLabel;

  /// No description provided for @cancelbuttonVoice.
  ///
  /// In en, this message translates to:
  /// **'press the cancel button to stop the process.'**
  String get cancelbuttonVoice;

  /// No description provided for @cancelbutton.
  ///
  /// In en, this message translates to:
  /// **'cancel button'**
  String get cancelbutton;

  /// No description provided for @reuseImageButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Reuse Image Button'**
  String get reuseImageButtonSemantic;

  /// No description provided for @playPauseLabel.
  ///
  /// In en, this message translates to:
  /// **'play and pause'**
  String get playPauseLabel;

  /// No description provided for @pressDownArrowKeyToCancelVoice.
  ///
  /// In en, this message translates to:
  /// **'press the down arrow key on the device to cancel the process'**
  String get pressDownArrowKeyToCancelVoice;

  /// No description provided for @resuseFeatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Reuse this feature!'**
  String get resuseFeatureLabel;

  /// No description provided for @backWithArrow.
  ///
  /// In en, this message translates to:
  /// **'ᐸ  Back'**
  String get backWithArrow;

  /// No description provided for @scenebuttonDevice.
  ///
  /// In en, this message translates to:
  /// **'Mode switched to scene detection'**
  String get scenebuttonDevice;

  /// No description provided for @museumbuttonDevice.
  ///
  /// In en, this message translates to:
  /// **'Mode switched to museum detection'**
  String get museumbuttonDevice;

  /// No description provided for @pressAnyKeyDevice.
  ///
  /// In en, this message translates to:
  /// **'press any key on the seekr device!'**
  String get pressAnyKeyDevice;

  /// No description provided for @deviceViewFinder.
  ///
  /// In en, this message translates to:
  /// **'Device View Finder'**
  String get deviceViewFinder;

  /// No description provided for @buttonToConnectAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Button to connect another Seeker Device'**
  String get buttonToConnectAnotherDevice;

  /// No description provided for @connectToDeviceButton.
  ///
  /// In en, this message translates to:
  /// **'Connect Seeker Device Button'**
  String get connectToDeviceButton;

  /// No description provided for @settingsPageSemantic.
  ///
  /// In en, this message translates to:
  /// **'seeker app settings page'**
  String get settingsPageSemantic;

  /// No description provided for @voiceSpeedDropdown.
  ///
  /// In en, this message translates to:
  /// **'Voice Speed, button'**
  String get voiceSpeedDropdown;

  /// No description provided for @speechPitchDropdown.
  ///
  /// In en, this message translates to:
  /// **'Voice Pitch, button'**
  String get speechPitchDropdown;

  /// No description provided for @speechLanguageDropDown.
  ///
  /// In en, this message translates to:
  /// **'Change Language Button'**
  String get speechLanguageDropDown;

  /// No description provided for @processSoundtoggle.
  ///
  /// In en, this message translates to:
  /// **'Processing Sound Toggle'**
  String get processSoundtoggle;

  /// No description provided for @howToUseSeekr.
  ///
  /// In en, this message translates to:
  /// **'How To Use Seekr'**
  String get howToUseSeekr;

  /// No description provided for @buttonToKnowMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Button to know more info about the app'**
  String get buttonToKnowMoreInfo;

  /// No description provided for @buttonToKnowUsage.
  ///
  /// In en, this message translates to:
  /// **'How to Use Seekr, Button'**
  String get buttonToKnowUsage;

  /// No description provided for @wantToExitLabel.
  ///
  /// In en, this message translates to:
  /// **'Want to exit the app?'**
  String get wantToExitLabel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @reuseFeature.
  ///
  /// In en, this message translates to:
  /// **'Reuse Feature'**
  String get reuseFeature;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing Image'**
  String get processingImage;

  /// No description provided for @connectedToDevice.
  ///
  /// In en, this message translates to:
  /// **'Connected to device'**
  String get connectedToDevice;

  /// No description provided for @compressingImage.
  ///
  /// In en, this message translates to:
  /// **'Compressing Image'**
  String get compressingImage;

  /// No description provided for @disconnectedFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from device'**
  String get disconnectedFromDevice;

  /// No description provided for @deviceSwitchingToPhotoMode.
  ///
  /// In en, this message translates to:
  /// **'Device switching to photo mode'**
  String get deviceSwitchingToPhotoMode;

  /// No description provided for @somethingWentWrongPhotoMode.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while device switching to photo mode'**
  String get somethingWentWrongPhotoMode;

  /// No description provided for @deviceIsDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Device is disconnected'**
  String get deviceIsDisconnected;

  /// No description provided for @deviceNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Device not connected'**
  String get deviceNotConnected;

  /// No description provided for @automaticVoicePlayback.
  ///
  /// In en, this message translates to:
  /// **'Automatic voice playback'**
  String get automaticVoicePlayback;

  /// No description provided for @enableCameraPreview.
  ///
  /// In en, this message translates to:
  /// **'Enable Camera preview'**
  String get enableCameraPreview;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @changeDeviceName.
  ///
  /// In en, this message translates to:
  /// **'Change Device WIFI Name'**
  String get changeDeviceName;

  /// No description provided for @restartDeviceChangeSSID.
  ///
  /// In en, this message translates to:
  /// **'Device has been shut down, please press power button to turn on device and connect with new SSID'**
  String get restartDeviceChangeSSID;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @textSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get textSizeExtraLarge;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @deviceBattery100.
  ///
  /// In en, this message translates to:
  /// **'Seekr device has hundred percent battery remaining'**
  String get deviceBattery100;

  /// No description provided for @deviceBattery70.
  ///
  /// In en, this message translates to:
  /// **'Seekr device has seventy percent battery remaining'**
  String get deviceBattery70;

  /// No description provided for @deviceBattery50.
  ///
  /// In en, this message translates to:
  /// **'Seekr device has fifty percent battery remaining'**
  String get deviceBattery50;

  /// No description provided for @deviceBattery25.
  ///
  /// In en, this message translates to:
  /// **'Seekr device has twenty five percent battery remaining'**
  String get deviceBattery25;

  /// No description provided for @deviceBatteryLow.
  ///
  /// In en, this message translates to:
  /// **'Seekr device is running out of battery'**
  String get deviceBatteryLow;

  /// No description provided for @deviceBatteryCharging.
  ///
  /// In en, this message translates to:
  /// **'Seekr device is charging'**
  String get deviceBatteryCharging;

  /// No description provided for @superMarketModeDevice.
  ///
  /// In en, this message translates to:
  /// **'Switched to supermarket mode'**
  String get superMarketModeDevice;

  /// No description provided for @adjustTextSizeButton.
  ///
  /// In en, this message translates to:
  /// **'Text size, button'**
  String get adjustTextSizeButton;

  /// No description provided for @changeWifiSemantic.
  ///
  /// In en, this message translates to:
  /// **'Change Device Wifi Name Button'**
  String get changeWifiSemantic;

  /// No description provided for @cameraTab.
  ///
  /// In en, this message translates to:
  /// **'Camera tab, One of Three'**
  String get cameraTab;

  /// No description provided for @cameraTabSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected, Camera tab, One of Three'**
  String get cameraTabSelected;

  /// No description provided for @deviceTab.
  ///
  /// In en, this message translates to:
  /// **'Device tab, Two of Three'**
  String get deviceTab;

  /// No description provided for @deviceTabSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected, Device tab, Two of Three'**
  String get deviceTabSelected;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings, tab, Three of Three'**
  String get settingsTab;

  /// No description provided for @settingsTabSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected, Settings, tab, Three of Three'**
  String get settingsTabSelected;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password Button'**
  String get forgotPasswordButton;

  /// No description provided for @grantCameraAccessLabel.
  ///
  /// In en, this message translates to:
  /// **' grant camera access'**
  String get grantCameraAccessLabel;

  /// No description provided for @grantMicrophoneAccessLabel.
  ///
  /// In en, this message translates to:
  /// **' grant microphone access'**
  String get grantMicrophoneAccessLabel;

  /// No description provided for @grantStorageAccessLabel.
  ///
  /// In en, this message translates to:
  /// **' grant storage access'**
  String get grantStorageAccessLabel;

  /// No description provided for @grantLocationAccessLabel.
  ///
  /// In en, this message translates to:
  /// **' grant location access'**
  String get grantLocationAccessLabel;

  /// No description provided for @grantCameraAccessSemantic.
  ///
  /// In en, this message translates to:
  /// **' grant camera access button'**
  String get grantCameraAccessSemantic;

  /// No description provided for @grantMicrophoneAccessSemantic.
  ///
  /// In en, this message translates to:
  /// **' grant microphone access button'**
  String get grantMicrophoneAccessSemantic;

  /// No description provided for @grantStorageAccessSemantic.
  ///
  /// In en, this message translates to:
  /// **' grant storage access button'**
  String get grantStorageAccessSemantic;

  /// No description provided for @grantLocationAccessSemantic.
  ///
  /// In en, this message translates to:
  /// **' grant location access button'**
  String get grantLocationAccessSemantic;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? '**
  String get areYouSure;

  /// No description provided for @deleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Once deleted, you will be logged off and your impact settings configuration will be deleted ?'**
  String get deleteDescription;

  /// No description provided for @requiredCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to use this feature.'**
  String get requiredCameraPermission;

  /// No description provided for @requiredLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use this feature.'**
  String get requiredLocationPermission;

  /// No description provided for @requestCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Request camera permission.'**
  String get requestCameraPermission;

  /// No description provided for @requestLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Request location permission.'**
  String get requestLocationPermission;

  /// No description provided for @connectToInternet.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet.'**
  String get connectToInternet;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check your connection.'**
  String get youAreOffline;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @selectionLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Already have an accoun? Double tap to login'**
  String get selectionLoginButton;

  /// No description provided for @selectionSignUpButton.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an accoun? Double tap to SignUp'**
  String get selectionSignUpButton;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Login with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithAppleButton.
  ///
  /// In en, this message translates to:
  /// **'Login with apple Button'**
  String get signInWithAppleButton;

  /// No description provided for @signInWithGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Login with google Button'**
  String get signInWithGoogleButton;

  /// No description provided for @yourPassword.
  ///
  /// In en, this message translates to:
  /// **'Password, Text field, Double tap to edit'**
  String get yourPassword;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get aiAssistant;

  /// No description provided for @modeSwitcedToYmca.
  ///
  /// In en, this message translates to:
  /// **'Mode switched to YMCA museum mode'**
  String get modeSwitcedToYmca;

  /// No description provided for @selectMuseumFromList.
  ///
  /// In en, this message translates to:
  /// **'Museum mode activated, Please select a museum from the list'**
  String get selectMuseumFromList;

  /// No description provided for @museumDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Museum mode deactivated'**
  String get museumDeactivated;

  /// No description provided for @semanticMuseum.
  ///
  /// In en, this message translates to:
  /// **'Museum, Button'**
  String get semanticMuseum;

  /// No description provided for @chooseMuseum.
  ///
  /// In en, this message translates to:
  /// **'Choose a museum'**
  String get chooseMuseum;

  /// No description provided for @ymca.
  ///
  /// In en, this message translates to:
  /// **'Y Musée (Hong Kong)'**
  String get ymca;

  /// No description provided for @ymcaButton.
  ///
  /// In en, this message translates to:
  /// **'Y Musée (Hong Kong)，Button'**
  String get ymcaButton;

  /// No description provided for @takeAPicture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takeAPicture;

  /// No description provided for @takeAPictureButton.
  ///
  /// In en, this message translates to:
  /// **'Take a picture，Button'**
  String get takeAPictureButton;

  /// No description provided for @walkingModeButton.
  ///
  /// In en, this message translates to:
  /// **'Walking mode, Button'**
  String get walkingModeButton;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @serverBusy.
  ///
  /// In en, this message translates to:
  /// **'Server busy, please try again later'**
  String get serverBusy;

  /// No description provided for @logOutSemantic.
  ///
  /// In en, this message translates to:
  /// **'Log out Button'**
  String get logOutSemantic;

  /// No description provided for @logOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out from account'**
  String get logOutLabel;

  /// No description provided for @seekrDevice.
  ///
  /// In en, this message translates to:
  /// **'Seekr Device'**
  String get seekrDevice;

  /// No description provided for @modeText.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get modeText;

  /// No description provided for @modeDepth.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get modeDepth;

  /// No description provided for @modeScene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get modeScene;

  /// No description provided for @modeSuperMarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get modeSuperMarket;

  /// No description provided for @modeMuseum.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get modeMuseum;

  /// No description provided for @modeWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get modeWalking;

  /// No description provided for @modeBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get modeBus;

  /// No description provided for @checkDeviceConnectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Check device connection status'**
  String get checkDeviceConnectionStatus;

  /// No description provided for @walkingModeStarted.
  ///
  /// In en, this message translates to:
  /// **'Mode switched to Walking. Walking mode started'**
  String get walkingModeStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'ja',
        'ko',
        'ms',
        'tl',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script+country codes are specified.
  switch (locale.toString()) {
    case 'zh_Hans_CN':
      return AppLocalizationsZhHansCn();
    case 'zh_Hant_HK':
      return AppLocalizationsZhHantHk();
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'tl':
      return AppLocalizationsTl();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
