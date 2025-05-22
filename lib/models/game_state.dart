import 'package:flutter/foundation.dart';
import 'level.dart';
import 'word.dart';

class GameState with ChangeNotifier {
  Level currentLevel;
  List<String> availableLetters = [];
  List<Word> foundWords = [];
  int score = 0;
  bool isLevelComplete = false;

  String currentWord = '';
  List<int> selectedLetterIndices = [];
  Map<int, int> letterUsageCounts = {};
  bool wasIncorrect = false;
  bool isDragging = false;

  GameState(this.currentLevel) {
    availableLetters = currentLevel.letters;
  }

  void selectLetter(int index) {
    if (index < 0 || index >= availableLetters.length) return;

    final selectedLetter = availableLetters[index];
    print('Selecting letter at index $index: $selectedLetter'); // Debug print
    final usedCount = selectedLetterIndices
        .map((i) => availableLetters[i])
        .where((l) => l == selectedLetter)
        .length;

    int maxAllowed = 1;
    for (final word in currentLevel.words) {
      final letterCount = word.text.toLowerCase().split('')
          .where((l) => l == selectedLetter.toLowerCase())
          .length;
      if (letterCount > maxAllowed) {
        maxAllowed = letterCount;
      }
    }

    if (usedCount >= maxAllowed) {
      print('Cannot select $selectedLetter: already used $usedCount times, max allowed: $maxAllowed');
      return;
    }

    selectedLetterIndices.add(index);
    currentWord += selectedLetter.toUpperCase();
    print('Current word: $currentWord, Selected indices: $selectedLetterIndices');
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

    final submittedWord = currentWord.toLowerCase();
    final isValid = currentLevel.words.any((word) =>
        word.text.toLowerCase() == submittedWord);

    print('Submitted word: $submittedWord, Valid: $isValid, Target words: ${currentLevel.words.map((w) => w.text).toList()}');

    if (isValid) {
      final wordObj = currentLevel.words.firstWhere(
          (word) => word.text.toLowerCase() == submittedWord);

      if (!foundWords.any((w) => w.text.toLowerCase() == wordObj.text.toLowerCase())) {
        foundWords.add(wordObj);
        score += wordObj.text.length * 10;
        if (foundWords.length == currentLevel.words.length) {
          isLevelComplete = true;
        }
        wasIncorrect = false;
      }
    } else if (currentWord.length > 1) {
      wasIncorrect = true;
    }

    currentWord = '';
    selectedLetterIndices = [];
    letterUsageCounts.clear();
    notifyListeners();
  }

  void resetLevel() {
    currentWord = '';
    selectedLetterIndices = [];
    letterUsageCounts.clear();
    foundWords = [];
    score = 0;
    isLevelComplete = false;
    wasIncorrect = false;
    notifyListeners();
  }

  void startDragging() {
    isDragging = true;
    notifyListeners();
  }

  void endDragging() {
    isDragging = false;
    notifyListeners();
  }
}