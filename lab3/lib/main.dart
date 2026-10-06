import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const RecipeIndexScreen(),
    );
  }
}

enum TextPlacement { center, bottom }

class RecipeIndexScreen extends StatelessWidget {
  const RecipeIndexScreen({super.key});

  Widget makeRow({
    required String sectionTitle,
    required List<String> imagePaths,
    required List<String> labels,
    required TextPlacement placement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            sectionTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(imagePaths.length, (index) {
            Widget avatar = CircleAvatar(
              radius: 38,
              backgroundImage: AssetImage(imagePaths[index]),
            );

            if (placement == TextPlacement.center) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  avatar,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: Colors.black45,
                    child: Text(
                      labels[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  avatar,
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            }
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Recipe Index'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item 1: Title
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Explore Categories',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          // Item 2: Row 1 - Protein
          makeRow(
            sectionTitle: 'By Protein',
            imagePaths: [
              'assets/images/beef.jpg',
              'assets/images/chicken.jpg',
              'assets/images/pork.jpg',
              'assets/images/seafood.jpg',
            ],
            labels: ['Beef', 'Chicken', 'Pork', 'Seafood'],
            placement: TextPlacement.center,
          ),

          // Item 3: Divider
          const Divider(indent: 16, endIndent: 16),

          // Item 4: Row 2 - Course
          makeRow(
            sectionTitle: 'By Course',
            imagePaths: [
              'assets/images/main_dishes.jpg',
              'assets/images/salad.jpg',
              'assets/images/side_dishes.jpg',
              'assets/images/crockpot.jpg',
            ],
            labels: ['Main dishes', 'Salad Recipes', 'Side Dishes', 'Crockpot'],
            placement: TextPlacement.bottom,
          ),

          // Item 5: Divider
          const Divider(indent: 16, endIndent: 16),

          // Item 6: Row 3 - Dessert
          makeRow(
            sectionTitle: 'By Dessert',
            imagePaths: [
              'assets/images/ice_cream.jpg',
              'assets/images/brownies.jpg',
              'assets/images/pies.jpg',
              'assets/images/cookies.jpg',
            ],
            labels: ['Ice Cream', 'Brownies', 'Pies', 'Cookies'],
            placement: TextPlacement.center,
          ),

          // Item 7: Divider
          const Divider(indent: 16, endIndent: 16),

          // Item 8: Footer
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'CST2335 Lab Demonstration',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}