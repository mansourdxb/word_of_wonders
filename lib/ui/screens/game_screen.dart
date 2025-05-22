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
  
  const GameScreen({super.key, required this.level});
  
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
        if (gameState.isLevelComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLevelCompleteDialog(context, gameState);
          });
        }

        if (gameState.wasIncorrect) {
          _shakeController.forward();
          gameState.wasIncorrect = false;
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/backgrounds/${widget.level.backgroundImage}',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              SizedBox(width: 10),
                              // Coins Indicator
                              Row(
                                children: [
                                  Icon(Icons.attach_money, color: Colors.yellow, size: 24),
                                  SizedBox(width: 4),
                                  Text(
                                    '150',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              // Gems Indicator
                              Row(
                                children: [
                                  Icon(Icons.diamond, color: Colors.blue, size: 24),
                                  SizedBox(width: 4),
                                  Text(
                                    '10',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Level ${widget.level.id}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                'Score: ${gameState.score}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          CrosswordGrid
                          (
                            words: widget.level.words,
                            foundWords: gameState.foundWords,
                            gridSize: 10,
                          ),
                        ],
                      ),
                    ),
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
                        color: Colors.transparent,
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
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 30),
                          child: LetterWheel(radius: 140),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    super.key,
    required this.words,
    this.foundWords = const [],
    this.gridSize = 10,
  });

  @override
  Widget build(BuildContext context) {
   if (words.isEmpty) {
  return Container(
    width: double.infinity,
    height: 300,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.transparent,
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


    int maxWordLength = words.fold<int>(0, (sum, word) => math.max(sum, word.text.length));
    final initialGridSize = math.max(maxWordLength * 2, 15);

    List<List<String?>> grid = List.generate(
      initialGridSize,
      (_) => List<String?>.filled(initialGridSize, null),
    );

    final gridCells = <String>{};
    final foundCells = <String>{};
    final wordPositionsMap = <String, List<String>>{};
    final assignedCells = <String, String>{};
    final placedWords = <String>{};

    final sortedWords = List<Word>.from(words);
    sortedWords.sort((a, b) => b.text.length.compareTo(a.text.length));

    if (sortedWords.isNotEmpty) {
      final firstWord = sortedWords[0].text.toUpperCase();
      final startRow = initialGridSize ~/ 2;
      final startCol = (initialGridSize - firstWord.length) ~/ 2;
      _placeWordHorizontally(grid, firstWord, startRow, startCol, 0, assignedCells, wordPositionsMap, gridCells);
      placedWords.add(firstWord);
      if (foundWords.any((w) => w.text.toUpperCase() == firstWord)) {
        for (final pos in wordPositionsMap[firstWord]!) {
          foundCells.add(pos);
        }
      }
    }

    List<String> remainingWords = sortedWords.skip(1).map((w) => w.text.toUpperCase()).toList();
    int attempts = 0;
    final maxAttempts = 100;

    print('Attempting to place words: $remainingWords, Found words: ${foundWords.map((w) => w.text).toList()}');

    while (remainingWords.isNotEmpty && attempts < maxAttempts) {
      attempts++;
      String? bestWord;
      int bestRow = 0;
      int bestCol = 0;
      bool bestIsHorizontal = false;
      int bestScore = -999999;

      for (final word in remainingWords) {
        for (int r = 0; r < initialGridSize; r++) {
          for (int c = 0; c < initialGridSize; c++) {
            final hScore = _scorePlacement(word, r, c, true, grid, assignedCells, initialGridSize);
            if (hScore > bestScore) {
              bestScore = hScore;
              bestWord = word;
              bestRow = r;
              bestCol = c;
              bestIsHorizontal = true;
            }
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

      if (bestWord != null && bestScore > -999999) {
        print('Placing $bestWord at ($bestRow, $bestCol), Horizontal: $bestIsHorizontal, Score: $bestScore');
        if (bestIsHorizontal) {
          _placeWordHorizontally(grid, bestWord, bestRow, bestCol, 0, assignedCells, wordPositionsMap, gridCells);
        } else {
          _placeWordVertically(grid, bestWord, bestRow, bestCol, 0, assignedCells, wordPositionsMap, gridCells);
        }
        placedWords.add(bestWord);
        remainingWords.remove(bestWord);
        if (foundWords.any((w) => w.text.toUpperCase() == bestWord)) {
          for (final pos in wordPositionsMap[bestWord]!) {
            foundCells.add(pos);
          }
        }
      } else {
        print('Failed to place any more words. Remaining: $remainingWords');
        break;
      }
    }

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

    minRow = math.max(0, minRow - 1);
    maxRow = math.min(initialGridSize - 1, maxRow + 1);
    minCol = math.max(0, minCol - 1);
    maxCol = math.min(initialGridSize - 1, maxCol + 1);

    final croppedRows = maxRow - minRow + 1;
    final croppedCols = maxCol - minCol + 1;

    return Container(
      width: double.infinity,
      height: 300,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
  color: Colors.transparent, // ✅ Transparent background
),

      child: Center(
        child: AspectRatio(
          aspectRatio: croppedCols / croppedRows,
          child: GridView.builder(
  shrinkWrap: true,
  padding: EdgeInsets.zero, // no extra padding
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: croppedCols,
    mainAxisSpacing: 0,
    crossAxisSpacing: 0,
    childAspectRatio: 1, // 1:1 square tiles
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
    color: isFoundCell
        ? Color(0xFF6534FF) // Purple background when word is found
        : isGridCell
            ? Colors.white // White background for valid letter boxes
            : Colors.transparent, // Fully transparent for unused tiles
    border: isGridCell
        ? Border.all(color: Colors.grey.shade300, width: 1.5)
        : null,
    borderRadius: BorderRadius.circular(6),
    boxShadow: isGridCell
        ? [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ]
        : [],
  ),
  alignment: Alignment.center,
 child: isFoundCell && letter != null
    ? Text(
        letter!,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: 1.5,
          fontFamily: 'Roboto', // or 'Poppins'/'Montserrat' if added
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

  int _scorePlacement(
    String word,
    int row,
    int col,
    bool isHorizontal,
    List<List<String?>> grid,
    Map<String, String> assignedCells,
    int gridSize,
  ) {
    int score = 0;
    bool isValid = isHorizontal
        ? _canPlaceHorizontally(grid, word, row, col, 0, gridSize, assignedCells)
        : _canPlaceVertically(grid, word, row, col, 0, gridSize, assignedCells);

    if (!isValid) return -999999;

    int intersections = 0;
    if (isHorizontal) {
      for (int i = 0; i < word.length; i++) {
        final c = col + i;
        final pos = '$row-$c';
        if (assignedCells.containsKey(pos) && assignedCells[pos] == word[i]) {
          intersections++;
          score += 1000;
          final abovePos = '${row - 1}-$c';
          final belowPos = '${row + 1}-$c';
          if (assignedCells.containsKey(abovePos) || assignedCells.containsKey(belowPos)) {
            score += 2000;
          }
        }
      }
    } else {
      for (int i = 0; i < word.length; i++) {
        final r = row + i;
        final pos = '$r-$col';
        if (assignedCells.containsKey(pos) && assignedCells[pos] == word[i]) {
          intersections++;
          score += 1000;
          final leftPos = '$r-${col - 1}';
          final rightPos = '$r-${col + 1}';
          if (assignedCells.containsKey(leftPos) || assignedCells.containsKey(rightPos)) {
            score += 2000;
          }
        }
      }
    }

    if (intersections == 0) {
      int minDistance = 999999;
      for (final existingPos in assignedCells.keys) {
        final parts = existingPos.split('-');
        final er = int.parse(parts[0]);
        final ec = int.parse(parts[1]);
        final distance = (row - er).abs() + (col - ec).abs();
        minDistance = math.min(minDistance, distance);
      }
      score -= minDistance * 10;
    }

    final centerRow = gridSize ~/ 2;
    final centerCol = gridSize ~/ 2;
    final centerDistance = (row - centerRow).abs() + (col - centerCol).abs();
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
    Map<String, String> assignedCells,
  ) {
    final actualStartRow = startRow - intersectionIdx;
    if (actualStartRow < 0 || actualStartRow + word.length > gridSize) return false;

    for (int i = 0; i < word.length; i++) {
      final r = actualStartRow + i;
      final pos = '$r-$startCol';
      if (assignedCells.containsKey(pos)) {
        if (assignedCells[pos] != word[i]) return false;
      } else {
        if (r != startRow) {
          final leftPos = '$r-${startCol - 1}';
          final rightPos = '$r-${startCol + 1}';
          if ((startCol > 0 && assignedCells.containsKey(leftPos)) ||
              (startCol < gridSize - 1 && assignedCells.containsKey(rightPos))) {
            continue;
          }
        }
      }
    }

    if (actualStartRow > 0) {
      final abovePos = '${actualStartRow - 1}-$startCol';
      if (assignedCells.containsKey(abovePos)) return false;
    }
    if (actualStartRow + word.length < gridSize) {
      final belowPos = '${actualStartRow + word.length}-$startCol';
      if (assignedCells.containsKey(belowPos)) return false;
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
    Map<String, String> assignedCells,
  ) {
    final actualStartCol = startCol - intersectionIdx;
    if (actualStartCol < 0 || actualStartCol + word.length > gridSize) return false;

    for (int i = 0; i < word.length; i++) {
      final c = actualStartCol + i;
      final pos = '$startRow-$c';
      if (assignedCells.containsKey(pos)) {
        if (assignedCells[pos] != word[i]) return false;
      } else {
        if (c != startCol) {
          final abovePos = '${startRow - 1}-$c';
          final belowPos = '${startRow + 1}-$c';
          if ((startRow > 0 && assignedCells.containsKey(abovePos)) ||
              (startRow < gridSize - 1 && assignedCells.containsKey(belowPos))) {
            continue;
          }
        }
      }
    }

    if (actualStartCol > 0) {
      final leftPos = '$startRow-${actualStartCol - 1}';
      if (assignedCells.containsKey(leftPos)) return false;
    }
    if (actualStartCol + word.length < gridSize) {
      final rightPos = '$startRow-${actualStartCol + word.length}';
      if (assignedCells.containsKey(rightPos)) return false;
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
    Set<String> gridCells,
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
    Set<String> gridCells,
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