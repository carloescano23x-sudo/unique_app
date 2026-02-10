import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
//hatdog
class TiltMazeGame extends FlameGame with HasCollisionDetection {
  Ball? ball;
  Vector2 velocity = Vector2.zero();
  Vector2 _inputDirection = Vector2.zero();
  final double moveSpeed = 150;

  int currentLevel = 0;
  final List<List<List<dynamic>>> levels = [];

  late TextComponent levelText;

  final double cellSize = 40; // Each maze cell is 40x40 pixels

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await ready();

    _buildLevels();
    _setupUI();
    _loadLevel(0);
  }

  void _setupUI() {
    levelText = TextComponent(
      text: 'Level 1',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 10),
      anchor: Anchor.topCenter,
    );
    add(levelText);
  }

  void setInput(Vector2 direction) {
    _inputDirection = direction.normalized();
  }

  void _buildLevels() {
    // LEVEL 1
    levels.add([
      ['S', 0, 1, 1, 1, 1, 1, 0, 0, 0],
      [1, 0, 1, 0, 0, 0, 1, 0, 1, 0],
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [1, 0, 0, 0, 1, 0, 0, 0, 1, 'G'],
      [1, 1, 1, 0, 1, 1, 1, 0, 1, 1],
      [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
      [1, 1, 1, 1, 1, 0, 1, 1, 1, 0],
      [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
      [0, 1, 1, 0, 1, 1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ]);

    // LEVEL 2
    levels.add([
      ['S', 0, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [1, 1, 1, 1, 1, 1, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
      [1, 1, 1, 1, 0, 1, 1, 1, 1, 0],
      [0, 0, 0, 1, 0, 0, 0, 0, 1, 0],
      [1, 1, 0, 1, 1, 1, 1, 0, 1, 'G'],
      [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
      [1, 1, 1, 1, 1, 0, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ]);

    // LEVEL 3
    levels.add([
      ['S', 1, 1, 0, 0, 0, 1, 1, 0, 0],
      [0, 0, 1, 0, 1, 0, 1, 0, 0, 0],
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 'G'],
      [1, 1, 1, 1, 1, 0, 1, 0, 1, 1],
      [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
      [0, 1, 1, 0, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
      [1, 0, 1, 1, 1, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ]);
  }

  void _loadLevel(int index) {
    children.whereType<Wall>().forEach(remove);
    children.whereType<Goal>().forEach(remove);
    ball?.removeFromParent();

    levelText.text = 'Level ${index + 1}';

    final grid = levels[index];
    Vector2? start;
    Vector2? goal;

    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        final cell = grid[y][x];
        final pos = Vector2(x * cellSize, y * cellSize);

        if (cell == 1) {
          add(Wall(pos, Vector2(cellSize, cellSize)));
        } else if (cell == 'S') {
          start = pos + Vector2(cellSize / 2, cellSize / 2);
        } else if (cell == 'G') {
          goal = pos + Vector2(cellSize / 2, cellSize / 2);
        }
      }
    }

    ball = Ball()..position = start!;
    add(ball!);

    add(Goal(goal!));
  }

  void nextLevel() {
    currentLevel++;
    if (currentLevel >= levels.length) {
      pauseEngine();
      levelText.text = '🏆 All Levels Completed!';
      return;
    }
    _loadLevel(currentLevel);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (ball == null) return;

    velocity = _inputDirection * moveSpeed;
    ball!.position += velocity * dt;

    ball!.x = ball!.x.clamp(ball!.radius, size.x - ball!.radius);
    ball!.y = ball!.y.clamp(ball!.radius, size.y - ball!.radius);
  }
}

/* ================= COMPONENTS ================= */

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<TiltMazeGame> {
  Ball()
      : super(
    radius: 14,
    paint: Paint()..color = Colors.lightBlueAccent,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Wall) {
      final avg =
          intersectionPoints.reduce((a, b) => a + b) / intersectionPoints.length.toDouble();
      final penetrationVector = position - avg;
      if (penetrationVector.length != 0) {
        position += penetrationVector.normalized() * 5;
      }
      game.velocity = Vector2.zero(); // <--- use 'game' instead of 'gameRef'
    }

    if (other is Goal) {
      game.velocity = Vector2.zero(); // <--- use 'game' instead of 'gameRef'
      game.nextLevel();               // <--- use 'game' instead of 'gameRef'
    }
  }
}


class Wall extends RectangleComponent with CollisionCallbacks {
  Wall(Vector2 position, Vector2 size)
      : super(
    position: position,
    size: size,
    paint: Paint()..color = Colors.grey.shade900,
  ) {
    add(RectangleHitbox());
  }
}

class Goal extends RectangleComponent with CollisionCallbacks {
  Goal(Vector2 position)
      : super(
    position: position,
    size: Vector2.all(36),
    paint: Paint()..color = Colors.greenAccent,
  ) {
    add(RectangleHitbox());
  }
}
