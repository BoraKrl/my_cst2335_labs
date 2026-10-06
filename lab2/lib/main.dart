import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Lab2Page(),
    );
  }
}

class Lab2Page extends StatefulWidget {
  const Lab2Page({super.key});

  @override
  State<Lab2Page> createState() => _Lab2PageState();
}

class _Lab2PageState extends State<Lab2Page> {
  // Text controllers to read user input values
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  // String variable initialized to question mark
  var imageSource = "images/question-mark.png";

  // State variable to switch languages
  bool isEnglish = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? "Flutter Demo Home Page" : "Page d'accueil Flutter"),
        actions: [
          // Button to toggle between languages
          TextButton(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
              });
            },
            child: Text(
              isEnglish ? "Français" : "English",
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Login name text field
            TextField(
              controller: loginController,
              decoration: InputDecoration(
                labelText: isEnglish ? "Login name" : "Nom d'utilisateur",
              ),
            ),

            // Password text field with obscureText: true
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isEnglish ? "password" : "mot de passe",
              ),
            ),

            const SizedBox(height: 16),

            // ElevatedButton reading the password string on tap
            ElevatedButton(
              onPressed: () {
                String password = passwordController.text;

                // Update imageSource using setState()
                setState(() {
                  if (password == "ASDF") {
                    imageSource = "images/idea.png";
                  } else {
                    imageSource = "images/stop.png";
                  }
                });
              },
              child: Text(isEnglish ? "Login" : "Connexion"),
            ),

            const SizedBox(height: 24),

            // Image 300 x 300
            Image.asset(
              imageSource,
              width: 300,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }
}