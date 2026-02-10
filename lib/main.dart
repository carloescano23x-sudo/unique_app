import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'tilt_maze_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tilt-Maze: Elemental Escape',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: GamePage(),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late TiltMazeGame _game;

  @override
  void initState() {
    super.initState();
    _game = TiltMazeGame();
  }

  void moveUp() => _game.setInput(Vector2(0, -1));
  void moveDown() => _game.setInput(Vector2(0, 1));
  void moveLeft() => _game.setInput(Vector2(-1, 0));
  void moveRight() => _game.setInput(Vector2(1, 0));
  void stopMove() => _game.setInput(Vector2.zero());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: _game),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrowButton(Icons.arrow_left, moveLeft, stopMove),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _arrowButton(Icons.arrow_drop_up, moveUp, stopMove),
                    SizedBox(height: 60),
                    _arrowButton(Icons.arrow_drop_down, moveDown, stopMove),
                  ],
                ),
                _arrowButton(Icons.arrow_right, moveRight, stopMove),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onPressedDown, VoidCallback onPressedUp) {
    return GestureDetector(
      onTapDown: (_) => onPressedDown(),
      onTapUp: (_) => onPressedUp(),
      onTapCancel: () => onPressedUp(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 40, color: Colors.white),
      ),
    );
  }
}
