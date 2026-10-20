import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String emailAddress = '';

  // Load variables from EncryptedSharedPreferences (Secure Storage)
  Future<void> loadData() async {
    firstName = await _storage.read(key: 'firstName') ?? '';
    lastName = await _storage.read(key: 'lastName') ?? '';
    phoneNumber = await _storage.read(key: 'phoneNumber') ?? '';
    emailAddress = await _storage.read(key: 'emailAddress') ?? '';
  }

  // Save variables to EncryptedSharedPreferences (Secure Storage)
  Future<void> saveData() async {
    await _storage.write(key: 'firstName', value: firstName);
    await _storage.write(key: 'lastName', value: lastName);
    await _storage.write(key: 'phoneNumber', value: phoneNumber);
    await _storage.write(key: 'emailAddress', value: emailAddress);
  }
}