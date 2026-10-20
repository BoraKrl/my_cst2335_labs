import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Week 4',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('fr', ''), // French (Second Language)
      ],
      home: LoginPage(onLanguageChange: _changeLanguage),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  const LoginPage({super.key, required this.onLanguageChange});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load saved credentials on startup & show SnackBar
  Future<void> _loadSavedCredentials() async {
    String? username = await _storage.read(key: 'username');
    String? password = await _storage.read(key: 'password');

    if (username != null &&
        username.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      setState(() {
        _usernameController.text = username;
        _passwordController.text = password;
      });

      // Show SnackBar when reloaded from preferences
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.credentialsLoaded),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  // Show AlertDialog on Login button click
  void _showSaveDialog() {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.dialogTitle),
          content: Text(loc.dialogMessage),
          actions: [
            TextButton(
              onPressed: () async {
                // Clear data from EncryptedSharedPreferences (Secure Storage)
                await _storage.deleteAll();
                if (mounted) Navigator.of(context).pop();
              },
              child: Text(loc.no),
            ),
            TextButton(
              onPressed: () async {
                // Save strings to EncryptedSharedPreferences (Secure Storage)
                await _storage.write(
                    key: 'username', value: _usernameController.text);
                await _storage.write(
                    key: 'password', value: _passwordController.text);
                if (mounted) Navigator.of(context).pop();
              },
              child: Text(loc.yes),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'en') {
                widget.onLanguageChange(const Locale('en'));
              } else if (value == 'fr') {
                widget.onLanguageChange(const Locale('fr'));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'fr', child: Text('Français')),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: loc.usernameHint),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: loc.passwordHint),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showSaveDialog,
              child: Text(loc.loginBtn),
            ),
          ],
        ),
      ),
    );
  }
}

// Localization Setup
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Lab Week 4',
      'usernameHint': 'Username / Email',
      'passwordHint': 'Password',
      'loginBtn': 'Login',
      'dialogTitle': 'Save Credentials?',
      'dialogMessage': 'Would you like to save your username and password for next time?',
      'yes': 'Yes',
      'no': 'No',
      'credentialsLoaded': 'Previous login name and passwords have been loaded.',
    },
    'fr': {
      'appTitle': 'Lab Semaine 4',
      'usernameHint': 'Nom d\'utilisateur / Email',
      'passwordHint': 'Mot de passe',
      'loginBtn': 'Connexion',
      'dialogTitle': 'Enregistrer les identifiants?',
      'dialogMessage': 'Voulez-vous enregistrer votre nom d\'utilisateur et votre mot de passe pour la prochaine fois?',
      'yes': 'Oui',
      'no': 'Non',
      'credentialsLoaded': 'Le nom d\'utilisateur et le mot de passe précédents ont été chargés.',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get usernameHint => _localizedValues[locale.languageCode]!['usernameHint']!;
  String get passwordHint => _localizedValues[locale.languageCode]!['passwordHint']!;
  String get loginBtn => _localizedValues[locale.languageCode]!['loginBtn']!;
  String get dialogTitle => _localizedValues[locale.languageCode]!['dialogTitle']!;
  String get dialogMessage => _localizedValues[locale.languageCode]!['dialogMessage']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get credentialsLoaded => _localizedValues[locale.languageCode]!['credentialsLoaded']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}