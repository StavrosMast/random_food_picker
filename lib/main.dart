import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Food Selector',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late CurvedAnimation _curvedAnimation;

  final foods = [
    'hamburger.png',
    'noodle.png',
    'pizza.png',
    'salad.png',
    'sushi.png',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _scrollController = ScrollController();

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.forward) {
        _scrollController.jumpTo(_curvedAnimation.value * 10000);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCenterLine() {
    return Positioned(
      top: 250,
      bottom: 250,
      left: MediaQuery.of(context).size.width / 2 - 2,
      child: Container(
        width: 4,
        color: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Random Food Selector')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: foods.length * 100,
                    itemBuilder: (context, index) {
                      String foodImagePath =
                          'images/${foods[index % foods.length]}';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(foodImagePath,
                            width: 100.0, height: 100.0),
                      );
                    },
                  ),
                ),
                _buildCenterLine(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: ElevatedButton(
              child: Text("Start"),
              onPressed: () {
                final random = Random();

                // Set the starting position
                final startPosition = random.nextInt(10000).toDouble();

                // Determine the end position based on the start
                final endPosition =
                    startPosition + (random.nextDouble() * 3000 + 500);

                _scrollController.jumpTo(startPosition);
                _animationController.reset();

                // Define the animation's path
                var scrollTween =
                    Tween<double>(begin: startPosition, end: endPosition);

                _animationController.addListener(() {
                  _scrollController
                      .jumpTo(scrollTween.evaluate(_curvedAnimation));
                });

                _animationController.forward().then((_) {
                  _animationController.removeListener(
                      () {}); // Remove the above listener to prevent memory leaks

                  final middlePosition = _scrollController.offset +
                      MediaQuery.of(context).size.width / 2 -
                      100.0;
                  final selectedFoodIndex =
                      ((middlePosition - 8) / 116).floor() % foods.length;
                  final selectedFood = foods[selectedFoodIndex];
                  final foodName = selectedFood.split('.').first;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('You got: $foodName'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset('images/$selectedFood',
                              width: 100.0, height: 100.0),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
