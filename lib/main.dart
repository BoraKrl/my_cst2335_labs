import 'package:flutter/material.dart';
import 'AppDatabase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  late AppDatabase db;
  List<Contact> contactList = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    _loadContacts(); // Requirement 2: Reload items on start
  }

  Future<void> _loadContacts() async {
    final contacts = await db.getAllContacts().get();
    setState(() {
      contactList = contacts;
    });
  }

  void _addContact() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    // Requirement 1: Insert into database when clicking Add
    db.saveContact(name, phone).then((generatedId) {
      nameController.clear();
      phoneController.clear();
      _loadContacts();
    });
  }

  void _deleteContact(int id) {
    // Requirement 3: Delete from database on long press
    db.deleteContact(id).then((_) {
      _loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 7 - Contacts Database')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addContact,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final item = contactList[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.phone),
                  onLongPress: () => _deleteContact(item.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
