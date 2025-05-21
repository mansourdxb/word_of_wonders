import 'word.dart';

class Level {
  final int id;
  final List<String> letters;
  final List<Word> words;
  final String? backgroundImage;
  final int starsRequired;
  final String difficulty;
  
  Level({
    required this.id,
    required this.letters,
    required this.words,
    this.backgroundImage,
    this.starsRequired = 0,
    this.difficulty = 'Medium',
  });
  
  // Factory method to create a level from JSON
  factory Level.fromJson(Map<String, dynamic> json) {
    // Handle letters format (comma-separated string or array)
    List<String> lettersList;
    if (json['letters'] is String) {
      // Parse comma-separated string
      lettersList = (json['letters'] as String).split(',').map((e) => e.trim()).toList();
    } else {
      // Handle array format
      lettersList = List<String>.from(json['letters']);
    }

    return Level(
      id: json['id'],
      letters: lettersList,
      words: (json['words'] as List).map((w) {
        if (w is String) {
          return Word(text: w);
        } else {
          return Word(
            text: w['text'],
            isBonusWord: w['isBonusWord'] ?? false,
          );
        }
      }).toList(),
      backgroundImage: json['backgroundImage'],
      starsRequired: json['starsRequired'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }
}