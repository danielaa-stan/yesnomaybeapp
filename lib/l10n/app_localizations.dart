import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'YesNoMaybe App'**
  String get appTitle;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameHint;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty!'**
  String get nameCannotBeEmpty;

  /// No description provided for @nameMustBeAtLeast3Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters.'**
  String get nameMustBeAtLeast3Characters;

  /// No description provided for @profileBioTitle.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBioTitle;

  /// No description provided for @profileBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This is all about you'**
  String get profileBioPlaceholder;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @chosenInterests.
  ///
  /// In en, this message translates to:
  /// **'Chosen interests'**
  String get chosenInterests;

  /// No description provided for @addMoreInterests.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get addMoreInterests;

  /// No description provided for @yourPollsHeader.
  ///
  /// In en, this message translates to:
  /// **'Your polls'**
  String get yourPollsHeader;

  /// No description provided for @yourVotesHeader.
  ///
  /// In en, this message translates to:
  /// **'Your votes'**
  String get yourVotesHeader;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelButton;

  /// No description provided for @pollTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get pollTitleHint;

  /// No description provided for @pollDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get pollDescriptionHint;

  /// No description provided for @buttonAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get buttonAddOption;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'POST'**
  String get postButton;

  /// No description provided for @changePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhotoButton;

  /// No description provided for @searchBarHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchBarHint;

  /// No description provided for @noPollsFound.
  ///
  /// In en, this message translates to:
  /// **'Sorry! Looks like there is no polls like that :('**
  String get noPollsFound;

  /// No description provided for @searchPageHeader.
  ///
  /// In en, this message translates to:
  /// **'Look it up!'**
  String get searchPageHeader;

  /// No description provided for @searchPageSubheader.
  ///
  /// In en, this message translates to:
  /// **'Or choose the HOT topic for today'**
  String get searchPageSubheader;

  /// No description provided for @messageNoPolls.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any polls yet.'**
  String get messageNoPolls;

  /// No description provided for @messageNoVotes.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t voted in any polls yet.'**
  String get messageNoVotes;

  /// No description provided for @makePickButton.
  ///
  /// In en, this message translates to:
  /// **'Make your pick'**
  String get makePickButton;

  /// No description provided for @moreButton.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreButton;

  /// No description provided for @lessButton.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get lessButton;

  /// No description provided for @homepageGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, '**
  String get homepageGreeting;

  /// No description provided for @homepageSubheader.
  ///
  /// In en, this message translates to:
  /// **'Ready to vote today?'**
  String get homepageSubheader;

  /// No description provided for @homepageHeader.
  ///
  /// In en, this message translates to:
  /// **'Hot picks for you'**
  String get homepageHeader;

  /// No description provided for @notificationsHeader.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsHeader;

  /// No description provided for @notificationsSubheader.
  ///
  /// In en, this message translates to:
  /// **'System notifications'**
  String get notificationsSubheader;

  /// No description provided for @notificationsDailyOption.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get notificationsDailyOption;

  /// No description provided for @notificationsActivityOption.
  ///
  /// In en, this message translates to:
  /// **'Activity on your poll'**
  String get notificationsActivityOption;

  /// No description provided for @notificationsInterestsOption.
  ///
  /// In en, this message translates to:
  /// **'New poll in your interests'**
  String get notificationsInterestsOption;

  /// No description provided for @createPollButton.
  ///
  /// In en, this message translates to:
  /// **'Create a poll'**
  String get createPollButton;

  /// No description provided for @findPollButton.
  ///
  /// In en, this message translates to:
  /// **'Find the poll'**
  String get findPollButton;

  /// No description provided for @snackBarVoteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your vote! :)'**
  String get snackBarVoteSuccess;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logoutButton;

  /// No description provided for @deletedPollSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Poll deleted successfully!'**
  String get deletedPollSnackBar;

  /// No description provided for @selectMoreInterests.
  ///
  /// In en, this message translates to:
  /// **'Select more interests'**
  String get selectMoreInterests;

  /// No description provided for @interestsConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get interestsConfirmButton;

  /// No description provided for @uploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo...'**
  String get uploadingPhoto;

  /// No description provided for @uploadPhotoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded successfully!'**
  String get uploadPhotoSuccess;

  /// No description provided for @uploadPhotoFail.
  ///
  /// In en, this message translates to:
  /// **'Photo upload failed!'**
  String get uploadPhotoFail;

  /// No description provided for @thePollsYouCreated.
  ///
  /// In en, this message translates to:
  /// **'Polls you proudly crafted'**
  String get thePollsYouCreated;

  /// No description provided for @thePollsYouVotedIn.
  ///
  /// In en, this message translates to:
  /// **'Your votes in action'**
  String get thePollsYouVotedIn;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title for your poll.'**
  String get enterTitle;

  /// No description provided for @provideAtLeast2Options.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least two valid poll options.'**
  String get provideAtLeast2Options;

  /// No description provided for @pollPostedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Poll posted successfully!'**
  String get pollPostedSuccessfully;

  /// No description provided for @setUpNewPoll.
  ///
  /// In en, this message translates to:
  /// **'Set up your new poll'**
  String get setUpNewPoll;

  /// No description provided for @giveSomeDetails.
  ///
  /// In en, this message translates to:
  /// **'Give some details'**
  String get giveSomeDetails;

  /// No description provided for @pollOption.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get pollOption;

  /// No description provided for @selectTag.
  ///
  /// In en, this message translates to:
  /// **'Select a tag'**
  String get selectTag;

  /// No description provided for @pollSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Poll successfully updated!'**
  String get pollSuccessfullyUpdated;

  /// No description provided for @errorUpdatingPoll.
  ///
  /// In en, this message translates to:
  /// **'Error updating poll'**
  String get errorUpdatingPoll;

  /// No description provided for @editPoll.
  ///
  /// In en, this message translates to:
  /// **'Edit poll'**
  String get editPoll;

  /// No description provided for @loggedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loggedInSuccessfully;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidEmailOrPassword;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get anErrorOccurred;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @emailCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email field cannot be empty.'**
  String get emailCannotBeEmpty;

  /// No description provided for @enterValidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email format.'**
  String get enterValidEmailFormat;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password field cannot be empty.'**
  String get passwordCannotBeEmpty;

  /// No description provided for @passwordMustHaveAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMustHaveAtLeast;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signInButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please check your email for verification.'**
  String get accountCreated;

  /// No description provided for @theEmailIsAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'The email address is already in use by another account.'**
  String get theEmailIsAlreadyInUse;

  /// No description provided for @hummm.
  ///
  /// In en, this message translates to:
  /// **'Hummm?'**
  String get hummm;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @agreeWith.
  ///
  /// In en, this message translates to:
  /// **'I agree with '**
  String get agreeWith;

  /// No description provided for @termsAndCond.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndCond;

  /// No description provided for @termsAndCondMessage.
  ///
  /// In en, this message translates to:
  /// **'Please agree to terms and conditions.'**
  String get termsAndCondMessage;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAnAccount;

  /// No description provided for @resultsAreProcessing.
  ///
  /// In en, this message translates to:
  /// **'Results are processing...'**
  String get resultsAreProcessing;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
