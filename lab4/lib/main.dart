import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_repository.dart';

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
      title: 'Lab Week 5',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ProfileRepository _repository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    await _repository.loadData();

    String? username = await _storage.read(key: 'username');
    String? password = await _storage.read(key: 'password');

    if (username != null && username.isNotEmpty) {
      setState(() {
        _usernameController.text = username;
        _passwordController.text = password ?? '';
      });
    }
  }

  void _performLogin() {
    String username = _usernameController.text.trim();
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('dialogTitle')),
        content: Text(loc.translate('dialogMessage')),
        actions: [
          TextButton(
            onPressed: () async {
              await _storage.deleteAll();
              if (mounted) {
                Navigator.of(context).pop();
                _navigateToProfile(username);
              }
            },
            child: Text(loc.translate('no')),
          ),
          TextButton(
            onPressed: () async {
              await _storage.write(key: 'username', value: username);
              await _storage.write(
                  key: 'password', value: _passwordController.text);
              if (mounted) {
                Navigator.of(context).pop();
                _navigateToProfile(username);
              }
            },
            child: Text(loc.translate('yes')),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          username: username,
          repository: _repository,
          onLanguageChange: widget.onLanguageChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('appTitle')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => widget.onLanguageChange(Locale(val)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'fr', child: Text('Français')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration:
              InputDecoration(labelText: loc.translate('usernameHint')),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration:
              InputDecoration(labelText: loc.translate('passwordHint')),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performLogin,
              child: Text(loc.translate('loginBtn')),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String username;
  final ProfileRepository repository;
  final Function(Locale) onLanguageChange;

  const ProfilePage({
    super.key,
    required this.username,
    required this.repository,
    required this.onLanguageChange,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.repository.firstName);
    _lastNameController =
        TextEditingController(text: widget.repository.lastName);
    _phoneController =
        TextEditingController(text: widget.repository.phoneNumber);
    _emailController =
        TextEditingController(text: widget.repository.emailAddress);

    _firstNameController.addListener(() {
      widget.repository.firstName = _firstNameController.text;
      widget.repository.saveData();
    });
    _lastNameController.addListener(() {
      widget.repository.lastName = _lastNameController.text;
      widget.repository.saveData();
    });
    _phoneController.addListener(() {
      widget.repository.phoneNumber = _phoneController.text;
      widget.repository.saveData();
    });
    _emailController.addListener(() {
      widget.repository.emailAddress = _emailController.text;
      widget.repository.saveData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.translate('welcomeBack')} ${widget.username}'),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  Future<void> _launchExternalUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorDialog();
      }
    } catch (_) {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('errorTitle')),
        content: Text(loc.translate('errorMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.translate('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('profileTitle')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => widget.onLanguageChange(Locale(val)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'fr', child: Text('Français')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: loc.translate('firstName'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: loc.translate('lastName'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.translate('phoneNumber'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      String phone = _phoneController.text.trim();
                      if (phone.isNotEmpty) {
                        _launchExternalUrl('tel:$phone');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      String phone = _phoneController.text.trim();
                      if (phone.isNotEmpty) {
                        _launchExternalUrl('sms:$phone');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: loc.translate('emailAddress'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.email),
                    onPressed: () {
                      String email = _emailController.text.trim();
                      if (email.isNotEmpty) {
                        _launchExternalUrl('mailto:$email');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Lab Week 5',
      'profileTitle': 'Profile Page',
      'usernameHint': 'Username / Email',
      'passwordHint': 'Password',
      'loginBtn': 'Login',
      'dialogTitle': 'Save Credentials?',
      'dialogMessage': 'Would you like to save your credentials?',
      'yes': 'Yes',
      'no': 'No',
      'welcomeBack': 'Welcome Back',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'phoneNumber': 'Phone Number',
      'emailAddress': 'Email address',
      'errorTitle': 'Unsupported Action',
      'errorMessage': 'This URL protocol is not supported on this device.',
      'ok': 'OK',
    },
    'fr': {
      'appTitle': 'Lab Semaine 5',
      'profileTitle': 'Page de Profil',
      'usernameHint': 'Nom d\'utilisateur / Email',
      'passwordHint': 'Mot de passe',
      'loginBtn': 'Connexion',
      'dialogTitle': 'Enregistrer les identifiants?',
      'dialogMessage': 'Voulez-vous enregistrer vos identifiants?',
      'yes': 'Oui',
      'no': 'Non',
      'welcomeBack': 'Bon retour',
      'firstName': 'Prénom',
      'lastName': 'Nom',
      'phoneNumber': 'Numéro de téléphone',
      'emailAddress': 'Adresse courriel',
      'errorTitle': 'Action non supportée',
      'errorMessage': 'Ce protocole URL n\'est pas pris en charge sur cet appareil.',
      'ok': 'OK',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}