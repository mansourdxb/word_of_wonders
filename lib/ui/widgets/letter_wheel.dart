import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';

class LetterWheel extends StatelessWidget {
  final double radius;
  
  const LetterWheel({super.key, this.radius = 140});
  
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final letters = gameState.availableLetters;
    
    // Calculate positions of all letters for line drawing and hit testing
    final Map<int, Offset> letterPositions = {};
    for (int i = 0; i < letters.length; i++) {
      final angle = 2 * pi * (i / letters.length);
      final x = radius * 0.7 * cos(angle);
      final y = radius * 0.7 * sin(angle);
      letterPositions[i] = Offset(radius + x, radius + y);
    }
    
    return GestureDetector(
      onPanStart: (details) {
        // Find if we're starting on a letter
        final localPosition = details.localPosition;
        for (int i = 0; i < letters.length; i++) {
          final letterPos = letterPositions[i]!;
          final distance = (letterPos - localPosition).distance;
          if (distance <= 25) {  // Inside the letter circle
            gameState.selectLetter(i);
            break;
          }
        }
      },
      onPanUpdate: (details) {
        // Check if we're over a new letter
        final localPosition = details.localPosition;
        
        // Variables to track the closest letter
        int? closestIndex;
        double minDistance = double.infinity;
        
        // Find the closest letter to the touch point
        for (int i = 0; i < letters.length; i++) {
          final letterPos = letterPositions[i]!;
          final distance = (letterPos - localPosition).distance;
          
          // Check if this is inside a letter circle and closer than any previous letter
          if (distance <= 25 && distance < minDistance) {
            closestIndex = i;
            minDistance = distance;
          }
        }
        
        // If we found a letter, select it - we no longer need to check if it was previously selected
        if (closestIndex != null) {
          // Prevent selecting the same letter twice in immediate succession (to avoid accidental double-taps)
          if (gameState.selectedLetterIndices.isEmpty || 
              gameState.selectedLetterIndices.last != closestIndex) {
            gameState.selectLetter(closestIndex);
          }
        }
      },
      onPanEnd: (details) {
        // Submit the word when the gesture ends
        gameState.submitWord();
      },
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Connection lines between selected letters
            if (gameState.selectedLetterIndices.length > 1)
              CustomPaint(
                size: Size(radius * 2, radius * 2),
                painter: ConnectionPainter(
                  letterPositions: letterPositions,
                  selectedIndices: gameState.selectedLetterIndices,
                  color: Colors.deepPurple,  // Match the purple from the screenshot
                ),
              ),
            
            // Letter buttons arranged in a circle
            ...List.generate(letters.length, (index) {
              // Calculate position on the circle
              final angle = 2 * pi * (index / letters.length);
              final x = radius * 0.7 * cos(angle);
              final y = radius * 0.7 * sin(angle);
              
              // A letter is selected if it appears in the selectedLetterIndices list
              final isSelected = gameState.selectedLetterIndices.contains(index);
              
              return Positioned(
                left: radius + x - 25,
                top: radius + y - 25,
                child: GestureDetector(
                  onTap: () {
                    gameState.selectLetter(index);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Colors.deepPurple  // Match the purple from the screenshot
                        : Colors.white,
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
                        letters[index].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // Center button (e.g., submit word)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.deepPurple,  // Using purple as shown in the screenshot
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: CircleBorder(),
                  onTap: () => gameState.submitWord(),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw connections between selected letters
class ConnectionPainter extends CustomPainter {
  final Map<int, Offset> letterPositions;
  final List<int> selectedIndices;
  final Color color;
  
  ConnectionPainter({
    required this.letterPositions,
    required this.selectedIndices,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Start at the first selected letter
    if (selectedIndices.isEmpty) return;
    
    final firstIndex = selectedIndices[0];
    final firstPos = letterPositions[firstIndex]!;
    path.moveTo(firstPos.dx, firstPos.dy);
    
    // Draw lines to each subsequent selected letter
    for (int i = 1; i < selectedIndices.length; i++) {
      final index = selectedIndices[i];
      final pos = letterPositions[index]!;
      path.lineTo(pos.dx, pos.dy);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.selectedIndices != selectedIndices;
  }
}