import 'package:flutter/foundation.dart';
import 'level.dart';
import 'word.dart';

class GameState with ChangeNotifier {
  Level currentLevel;
  List<String> availableLetters = [];
  List<Word> foundWords = [];
  int score = 0;
  bool isLevelComplete = false;
  
  // Current word being formed
  String currentWord = '';
  List<int> selectedLetterIndices = [];
  
  // Track letter usage counts for the current word
  Map<int, int> letterUsageCounts = {};
  
  // Track if the word was just incorrect (for animations)
  bool wasIncorrect = false;
  
  // Current dragging state
  bool isDragging = false;
  
  void shuffleLetters() {
  availableLetters.shuffle();
  notifyListeners();
}

  GameState(this.currentLevel) {
    availableLetters = currentLevel.letters;
  }
  
  void selectLetter(int index) {
    final selectedLetter = availableLetters[index];

    // Count how many times this letter has been used so far
    final usedCount = selectedLetterIndices
        .map((i) => availableLetters[i])
        .where((l) => l == selectedLetter)
        .length;

    // Check all words in the level to find the maximum number of times
    // any letter is used in a single word
    int maxAllowed = 1; // Default to 1
    
    for (final word in currentLevel.words) {
      // Count occurrences of this letter in the word
      final letterCount = word.text.toLowerCase().split('')
          .where((l) => l == selectedLetter.toLowerCase())
          .length;
      
      // Update max if we found a word with more occurrences
      if (letterCount > maxAllowed) {
        maxAllowed = letterCount;
      }
    }

    if (usedCount >= maxAllowed) {
      return; // Exceeds allowed count
    }

    selectedLetterIndices.add(index);
    currentWord += selectedLetter;
    notifyListeners();
  }
  
  void deselectLastLetter() {
    if (selectedLetterIndices.isEmpty) return;

    selectedLetterIndices.removeLast();
    currentWord = currentWord.substring(0, currentWord.length - 1);
    notifyListeners();
  }
  
  void submitWord() {
    if (currentWord.isEmpty) return;
    
    // Check if word is valid and exists in the level's word list
    final isValid = currentLevel.words.any((word) => 
      word.text.toLowerCase() == currentWord.toLowerCase());
    
    if (isValid) {
      final wordObj = currentLevel.words.firstWhere(
        (word) => word.text.toLowerCase() == currentWord.toLowerCase());
      
      // Add to found words if not already found
      if (!foundWords.any((w) => w.text == wordObj.text)) {
        foundWords.add(wordObj);
        score += wordObj.text.length * 10;
        
        // Check if level is complete
        if (foundWords.length == currentLevel.words.length) {
          isLevelComplete = true;
        }
        
        // Reset incorrect flag
        wasIncorrect = false;
      }
    } else if (currentWord.length > 1) {
      // Word was incorrect (only consider it incorrect if it's more than one letter)
      wasIncorrect = true;
    }
    
    // Reset current word
    currentWord = '';
    selectedLetterIndices = [];
    letterUsageCounts.clear(); // Clear the usage counts
    notifyListeners();
  }
  
  void resetLevel() {
    currentWord = '';
    selectedLetterIndices = [];
    letterUsageCounts.clear(); // Clear the usage counts
    foundWords = [];
    score = 0;
    isLevelComplete = false;
    wasIncorrect = false;
    notifyListeners();
  }
  
  // Start dragging mode (for letter connections)
  void startDragging() {
    isDragging = true;
    notifyListeners();
  }
  
  // End dragging mode
  void endDragging() {
    isDragging = false;
    notifyListeners();
  }
}