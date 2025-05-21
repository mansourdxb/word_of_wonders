import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/letter_wheel.dart';
import '../widgets/word_display.dart';
import '../../models/game_state.dart';
import '../../models/level.dart';
import '../../services/level_service.dart';
import 'package:word_of_wonders_original/models/word.dart';
import '../../models/game_state.dart';
import '../../models/level.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GameScreen extends StatefulWidget {
  final Level level;
  
  const GameScreen({Key? key, required this.level}) : super(key: key);
  
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup shake animation for incorrect words
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
  
  void _showLevelCompleteDialog(BuildContext context, GameState gameState) {
    // Calculate stars based on performance
    final totalWordLength = widget.level.words
        .fold<int>(0, (sum, word) => sum + word.text.length);
    
    final perfectScore = totalWordLength * 10;
    final percentage = gameState.score / perfectScore;
    
    int stars = 1;
    if (percentage >= 0.7) stars = 2;
    if (percentage >= 0.9) stars = 3;
    
    // Save progress
    Provider.of<LevelService>(context, listen: false)
        .saveProgress(widget.level.id, stars, gameState.score);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Score: ${gameState.score}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => 
                Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: i < stars ? Colors.amber : Colors.grey.shade400,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to level select
            },
            child: Text('Back to Levels'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Go to next level if available
              if (widget.level.id < 10) { // Assume 10 levels for demo
                Provider.of<LevelService>(context, listen: false)
                    .getLevel(widget.level.id + 1)
                    .then((nextLevel) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(level: nextLevel),
                    ),
                  );
                });
              } else {
                Navigator.pop(context); // Return to level select
              }
            },
            child: Text('Next Level'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(widget.level),
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Check if level is complete
          if (gameState.isLevelComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLevelCompleteDialog(context, gameState);
            });
          }
          
          // Check if incorrect word was submitted and shake
          if (gameState.wasIncorrect) {
            _shakeController.forward();
            gameState.wasIncorrect = false; // Reset flag
          }
          
          return Scaffold(
            backgroundColor: Color(0xFFF8F6FA),  // Light purple background shown in the screenshot
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Level ${widget.level.id}',
                style: TextStyle(color: Colors.black87),
              ),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      'Score: ${gameState.score}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
              // Found words display with crossword layout
// Found words display with crossword layout
Container(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Found Words: ${gameState.foundWords.length}/${widget.level.words.length}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8),
 CrosswordGrid(
  words: widget.level.words,
  foundWords: gameState.foundWords,
  gridSize: 10,
),


    ],
  ),
),
                  
                  // Current word being formed
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: _shakeAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          gameState.currentWord.toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Letter wheel - centered in the remaining space
                  Expanded(
                    child: Center(
                      child: LetterWheel(radius: 150),
                    ),
                  ),
                  
                  // Game controls
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.refresh, size: 28),
                          onPressed: () => gameState.resetLevel(),
                        ),
                        IconButton(
                          icon: Icon(Icons.backspace, size: 28),
                          onPressed: () => gameState.deselectLastLetter(),
                        ),
                        IconButton(
                          icon: Icon(Icons.help_outline, size: 28),
                          onPressed: () {
                            // Show hint
                            if (gameState.foundWords.length < widget.level.words.length) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Hint: Try to find a ${widget.level.words[gameState.foundWords.length].text.length}-letter word'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// New widget for the crossword grid display


class CrosswordGrid extends StatelessWidget {
  final List<Word> words;
  final List<Word> foundWords;
  final int gridSize;

  const CrosswordGrid({
    Key? key,
    required this.words,
    this.foundWords = const [],
    this.gridSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no words are provided, show an empty container
    if (words.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "No words available for this level",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Step 1: Calculate optimal grid size based on words
    int maxWordLength = 0;
    for (final word in words) {
      maxWordLength = math.max(maxWordLength, word.text.length);
    }
    
    // Increase initial grid size to give more room for connections
    final initialGridSize = math.max(maxWordLength * 2, 15);
    
    // Create an initial grid
    List<List<String?>> grid = List.generate(
      initialGridSize,
      (_) => List<String?>.filled(initialGridSize, null),
    );

    // Track all valid cells in the grid
    final gridCells = <String>{};
    
    // Track cells that contain found words (to highlight them)
    final foundCells = <String>{};
    
    // Maps each word to its positions in the grid
    final wordPositionsMap = <String, List<String>>{};
    
    // Track which cells have already been assigned
    final assignedCells = <String, String>{};  // Maps position to letter
    
    // Track which words have been successfully placed
    final placedWords = <String>{};

    // Sort words by length (descending)
    final sortedWords = List<Word>.from(words);
    sortedWords.sort((a, b) => b.text.length.compareTo(a.text.length));
    
    // Place the first word horizontally in the middle
    if (sortedWords.isNotEmpty) {
      final firstWord = sortedWords[0].text.toUpperCase();
      final startRow = initialGridSize ~/ 2;
      final startCol = (initialGridSize - firstWord.length) ~/ 2;
      
      _placeWordHorizontally(grid, firstWord, startRow, startCol, 0, 
                          assignedCells, wordPositionsMap, gridCells);
      placedWords.add(firstWord);
      
      if (foundWords.any((w) => w.text.toUpperCase() == firstWord)) {
        for (final pos in wordPositionsMap[firstWord]!) {
          foundCells.add(pos);
        }
      }
    }

    // Now place remaining words with the scoring approach
    List<String> remainingWords = sortedWords
        .skip(1)
        .map((w) => w.text.toUpperCase())
        .toList();

    int attempts = 0;
    final maxAttempts = 100; // Try harder to place words

    while (remainingWords.isNotEmpty && attempts < maxAttempts) {
      attempts++;

      String? bestWord;
      int bestRow = 0;
      int bestCol = 0;
      bool bestIsHorizontal = false;
      int bestScore = -999999; // Use very negative value to ensure placement
      
      // Try all remaining words in all possible positions
      for (final word in remainingWords) {
        // Try each possible grid position and orientation
        for (int r = 0; r < initialGridSize; r++) {
          for (int c = 0; c < initialGridSize; c++) {
            // Try horizontal placement
            final hScore = _scorePlacement(word, r, c, true, grid, assignedCells, initialGridSize);
            if (hScore > bestScore) {
              bestScore = hScore;
              bestWord = word;
              bestRow = r;
              bestCol = c;
              bestIsHorizontal = true;
            }
            
            // Try vertical placement
            final vScore = _scorePlacement(word, r, c, false, grid, assignedCells, initialGridSize);
            if (vScore > bestScore) {
              bestScore = vScore;
              bestWord = word;
              bestRow = r;
              bestCol = c;
              bestIsHorizontal = false;
            }
          }
        }
      }
      
      // If we found a valid placement, place the word
      if (bestWord != null) {
        if (bestIsHorizontal) {
          _placeWordHorizontally(grid, bestWord, bestRow, bestCol, 0,
                                assignedCells, wordPositionsMap, gridCells);
        } else {
          _placeWordVertically(grid, bestWord, bestRow, bestCol, 0,
                              assignedCells, wordPositionsMap, gridCells);
        }
        
        placedWords.add(bestWord);
        remainingWords.remove(bestWord);
        
        // Mark found cells
        if (foundWords.any((w) => w.text.toUpperCase() == bestWord)) {
          for (final pos in wordPositionsMap[bestWord]!) {
            foundCells.add(pos);
          }
        }
      } else {
        // If we couldn't find any valid placement, just break
        break;
      }
    }
    
    // Step 3: Crop the grid to remove unnecessary rows/columns
    int minRow = initialGridSize;
    int maxRow = 0;
    int minCol = initialGridSize;
    int maxCol = 0;
    
    for (final pos in gridCells) {
      final parts = pos.split('-');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);
      
      minRow = math.min(r, minRow);
      maxRow = math.max(r, maxRow);
      minCol = math.min(c, minCol);
      maxCol = math.max(c, maxCol);
    }
    
    // Add a one-cell padding around the grid
    minRow = math.max(0, minRow - 1);
    maxRow = math.min(initialGridSize - 1, maxRow + 1);
    minCol = math.max(0, minCol - 1);
    maxCol = math.min(initialGridSize - 1, maxCol + 1);
    
    // Calculate dimensions of the cropped grid
    final croppedRows = maxRow - minRow + 1;
    final croppedCols = maxCol - minCol + 1;
    
    // Step 4: Render the cropped grid
    return Container(
      width: double.infinity,
      height: 300,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: AspectRatio(
          aspectRatio: croppedCols / croppedRows,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: croppedCols,
              childAspectRatio: 1,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: croppedRows * croppedCols,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final row = minRow + (index ~/ croppedCols);
              final col = minCol + (index % croppedCols);
              final pos = '$row-$col';
              final String? letter = grid[row][col];
              final bool isGridCell = gridCells.contains(pos);
              final bool isFoundCell = foundCells.contains(pos);
              
              return Container(
                decoration: BoxDecoration(
                  color: isFoundCell ? Color(0xFFCFEDC4) : (isGridCell ? Colors.white : Colors.transparent),
                  border: isGridCell ? Border.all(color: Colors.grey.shade300, width: 1) : null,
                ),
                alignment: Alignment.center,
                child: isFoundCell && letter != null
                    ? Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
  
  // Evaluate the placement score for a word
  int _scorePlacement(
    String word,
    int row, 
    int col, 
    bool isHorizontal,
    List<List<String?>> grid,
    Map<String, String> assignedCells,
    int gridSize
  ) {
    // Start with a base score
    int score = 0;
    
    // Check if this placement is valid first
    bool isValid = isHorizontal ? 
      _canPlaceHorizontally(grid, word, row, col, 0, gridSize, assignedCells) :
      _canPlaceVertically(grid, word, row, col, 0, gridSize, assignedCells);
    
    if (!isValid) return -999999; // Very negative score for invalid placements
    
    // Count intersections - this is critical for connecting words
    int intersections = 0;
    
    if (isHorizontal) {
      for (int i = 0; i < word.length; i++) {
        final c = col + i;
        final pos = '$row-$c';
        
        if (assignedCells.containsKey(pos) && assignedCells[pos] == word[i]) {
          intersections++;
          score += 1000; // Highly reward intersections
          
          // Check if this creates a real crossword connection
          final abovePos = '${row - 1}-$c';
          final belowPos = '${row + 1}-$c';
          
          if (assignedCells.containsKey(abovePos) || assignedCells.containsKey(belowPos)) {
            score += 2000; // Even higher reward for true crossword connections
          }
        }
      }
    } else {
      // Vertical placement
      for (int i = 0; i < word.length; i++) {
        final r = row + i;
        final pos = '$r-$col';
        
        if (assignedCells.containsKey(pos) && assignedCells[pos] == word[i]) {
          intersections++;
          score += 1000; // Highly reward intersections
          
          // Check if this creates a real crossword connection
          final leftPos = '$r-${col - 1}';
          final rightPos = '$r-${col + 1}';
          
          if (assignedCells.containsKey(leftPos) || assignedCells.containsKey(rightPos)) {
            score += 2000; // Even higher reward for true crossword connections
          }
        }
      }
    }
    
    // If no intersections found, strongly prefer placements close to existing words
    if (intersections == 0) {
      // Find minimum distance to any existing word
      int minDistance = 999999;
      
      for (final existingPos in assignedCells.keys) {
        final parts = existingPos.split('-');
        final er = int.parse(parts[0]);
        final ec = int.parse(parts[1]);
        
        // Use Manhattan distance
        final distance = (row - er).abs() + (col - ec).abs();
        minDistance = math.min(minDistance, distance);
      }
      
      // Score is inverse to distance - closer is better
      // Use a smaller factor to still prioritize intersections
      score -= minDistance * 10;
    }
    
    // Prefer placements at the center of the grid
    final centerRow = gridSize ~/ 2;
    final centerCol = gridSize ~/ 2;
    final centerDistance = (row - centerRow).abs() + (col - centerCol).abs();
    
    // Small penalty for distance from center (less important than intersections)
    score -= centerDistance;
    
    return score;
  }
  
  bool _canPlaceVertically(
    List<List<String?>> grid, 
    String word, 
    int startRow, 
    int startCol, 
    int intersectionIdx,
    int gridSize,
    Map<String, String> assignedCells
  ) {
    // Calculate the actual starting row based on the intersection index
    final actualStartRow = startRow - intersectionIdx;
    
    // Check if the word would fit within grid bounds
    if (actualStartRow < 0 || actualStartRow + word.length > gridSize) {
      return false;
    }
    
    // Check if the placement works with existing letters
    for (int i = 0; i < word.length; i++) {
      final r = actualStartRow + i;
      final pos = '$r-$startCol';
      
      if (assignedCells.containsKey(pos)) {
        // If cell already has a letter, it must match our word
        if (assignedCells[pos] != word[i]) {
          return false;
        }
      } else {
        // If cell is empty, check if adjacent cells horizontally are also empty
        // (to maintain crossword style - prevent words from running side by side)
        final leftPos = '$r-${startCol - 1}';
        final rightPos = '$r-${startCol + 1}';
        
        // Skip intersection point
        if (r == startRow) continue;
        
        // Check left cell is within bounds and empty
        if (startCol > 0 && assignedCells.containsKey(leftPos)) {
          return false;
        }
        
        // Check right cell is within bounds and empty
        if (startCol < gridSize - 1 && assignedCells.containsKey(rightPos)) {
          return false;
        }
      }
    }
    
    // Also check if there's space around the start and end of the word
    if (actualStartRow > 0) {
      final abovePos = '${actualStartRow - 1}-$startCol';
      if (assignedCells.containsKey(abovePos)) {
        return false;
      }
    }
    
    if (actualStartRow + word.length < gridSize) {
      final belowPos = '${actualStartRow + word.length}-$startCol';
      if (assignedCells.containsKey(belowPos)) {
        return false;
      }
    }
    
    return true;
  }
  
  bool _canPlaceHorizontally(
    List<List<String?>> grid, 
    String word, 
    int startRow, 
    int startCol, 
    int intersectionIdx,
    int gridSize,
    Map<String, String> assignedCells
  ) {
    // Calculate the actual starting column based on the intersection index
    final actualStartCol = startCol - intersectionIdx;
    
    // Check if the word would fit within grid bounds
    if (actualStartCol < 0 || actualStartCol + word.length > gridSize) {
      return false;
    }
    
    // Check if the placement works with existing letters
    for (int i = 0; i < word.length; i++) {
      final c = actualStartCol + i;
      final pos = '$startRow-$c';
      
      if (assignedCells.containsKey(pos)) {
        // If cell already has a letter, it must match our word
        if (assignedCells[pos] != word[i]) {
          return false;
        }
      } else {
        // If cell is empty, check if adjacent cells vertically are also empty
        // (to maintain crossword style - prevent words from running side by side)
        final abovePos = '${startRow - 1}-$c';
        final belowPos = '${startRow + 1}-$c';
        
        // Skip intersection point
        if (c == startCol) continue;
        
        // Check above cell is within bounds and empty
        if (startRow > 0 && assignedCells.containsKey(abovePos)) {
          return false;
        }
        
        // Check below cell is within bounds and empty
        if (startRow < gridSize - 1 && assignedCells.containsKey(belowPos)) {
          return false;
        }
      }
    }
    
    // Also check if there's space around the start and end of the word
    if (actualStartCol > 0) {
      final leftPos = '$startRow-${actualStartCol - 1}';
      if (assignedCells.containsKey(leftPos)) {
        return false;
      }
    }
    
    if (actualStartCol + word.length < gridSize) {
      final rightPos = '$startRow-${actualStartCol + word.length}';
      if (assignedCells.containsKey(rightPos)) {
        return false;
      }
    }
    
    return true;
  }
  
  void _placeWordVertically(
    List<List<String?>> grid,
    String word,
    int intersectionRow,
    int col,
    int intersectionIdx,
    Map<String, String> assignedCells,
    Map<String, List<String>> wordPositionsMap,
    Set<String> gridCells
  ) {
    final startRow = intersectionRow - intersectionIdx;
    wordPositionsMap[word] = [];
    
    for (int i = 0; i < word.length; i++) {
      final r = startRow + i;
      final pos = '$r-$col';
      
      grid[r][col] = word[i];
      assignedCells[pos] = word[i];
      wordPositionsMap[word]!.add(pos);
      gridCells.add(pos);
    }
  }
  
  void _placeWordHorizontally(
    List<List<String?>> grid,
    String word,
    int row,
    int intersectionCol,
    int intersectionIdx,
    Map<String, String> assignedCells,
    Map<String, List<String>> wordPositionsMap,
    Set<String> gridCells
  ) {
    final startCol = intersectionCol - intersectionIdx;
    wordPositionsMap[word] = [];
    
    for (int i = 0; i < word.length; i++) {
      final c = startCol + i;
      final pos = '$row-$c';
      
      grid[row][c] = word[i];
      assignedCells[pos] = word[i];
      wordPositionsMap[word]!.add(pos);
      gridCells.add(pos);
    }
  }
}

// Helper class to represent a word placement on the grid
class WordPlacement {
  final String word;
  final List<String> positions;
  final bool isHorizontal;
  
  WordPlacement({
    required this.word,
    required this.positions,
    required this.isHorizontal,
  });
}