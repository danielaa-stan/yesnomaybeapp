import 'package:flutter/material.dart';
import 'pages/splashscreen.dart';
import 'package:yesnomaybeapp/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'providers/polls_provider.dart';
import 'package:provider/provider.dart';
import 'repositories/polls_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yesnomaybeapp/l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( // Firebase Initialization
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://rcjiglcpovusotpxshox.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjamlnbGNwb3Z1c290cHhzaG94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MjcxNDksImV4cCI6MjA4MDAwMzE0OX0.fz3J1EMjQAsjzLnsBE4sNXwbbTIvDkeQfz53IRMmkvc',
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = const Locale('en', '');
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialLocale();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserLocale(user.uid);
      }
    });
  }

  // async language load
  void _loadInitialLocale() async {
    final user = FirebaseAuth.instance.currentUser;
    String langCode = 'en';

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // read from firestore
      langCode = userDoc.data()?['preferredLanguageCode'] as String? ?? 'en';
    }

    setState(() {
      _currentLocale = Locale(langCode, '');
      _isDataLoaded = true;
    });
  }

  void _loadUserLocale(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final langCode = userDoc.data()?['preferredLanguageCode'] as String? ?? 'en';

    if (mounted) {
      setState(() {
        _currentLocale = Locale(langCode, '');
      });
    }
  }


  void changeLocale(Locale newLocale) async {
    final user = FirebaseAuth.instance.currentUser;

    // save to Firestore
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'preferredLanguageCode': newLocale.languageCode,
      }, SetOptions(merge: true));
    }

    setState(() {
      _currentLocale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PollsRepository pollsRepository = FirestorePollsRepository();

    return ChangeNotifierProvider(
      create: (context) => PollsProvider(pollsRepository)..fetchPolls(),
      child: Builder(
        builder: (context) {
          // Підписка на authStateChanges
          FirebaseAuth.instance.authStateChanges().listen((user) {
            if (user != null) {
              // отримуємо провайдер
              final pollsProvider =
              Provider.of<PollsProvider>(context, listen: false);

              // підвантажуємо всі опитування та votedOptionsMap
              pollsProvider.fetchPolls();
            }
          });

          return MaterialApp(
            title: 'YesNoMaybe',
            theme: ThemeData(
              primarySwatch: Colors.teal,
            ),
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            locale: _currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('uk', ''),
            ],
          );
        },
      ),
    );
  }
}