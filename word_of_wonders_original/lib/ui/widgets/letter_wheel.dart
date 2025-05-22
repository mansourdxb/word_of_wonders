import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import 'dart:math' as math;

class LetterWheel extends StatelessWidget {
  final double radius;

  const LetterWheel({super.key, this.radius = 140});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final letters = gameState.availableLetters;
    final selectedIndex = gameState.selectedLetterIndices.isNotEmpty ? gameState.selectedLetterIndices.last : -1;

    return GestureDetector(
      onTapUp: (details) {
        final localPosition = details.localPosition;
        final center = Offset(radius, radius);
        final distance = (center - localPosition).distance;

        if (distance <= 60) {
          if (selectedIndex >= 0) {
            print('Submitting word from LetterWheel: ${gameState.currentWord}');
            gameState.submitWord();
          }
        } else {
          final dx = localPosition.dx - radius;
          final dy = localPosition.dy - radius;
          int newIndex = -1;

          if (dx.abs() > dy.abs()) {
            newIndex = dx > 0 ? 1 : 3; // Right or Left
          } else {
            newIndex = dy > 0 ? 2 : 0; // Down or Up
          }

          if (newIndex >= 0 && newIndex < letters.length) {
            gameState.selectLetter(newIndex);
          }
        }
      },
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: selectedIndex >= 0 ? Colors.deepPurple : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      selectedIndex >= 0 ? letters[selectedIndex].toUpperCase() : '',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex >= 0 ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (selectedIndex >= 0)
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                  ],
                ),
              ),
            ),
            ...List.generate(4, (index) {
              final angle = index * math.pi / 2;
              final x = radius + radius * 0.6 * math.cos(angle);
              final y = radius + radius * 0.6 * math.sin(angle);
              final isSelected = selectedIndex == index;

              return Positioned(
                left: x - 40,
                top: y - 40,
                child: GestureDetector(
                  onTap: () {
                    gameState.selectLetter(index);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        index < letters.length ? letters[index].toUpperCase() : '',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}