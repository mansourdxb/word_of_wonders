class WordValidator {
  // Check if a word is in the dictionary
  Future<bool> isValidWord(String word) async {
    // In a real implementation, you would:
    // 1. Check against a local dictionary file
    // 2. Or call an API if online validation is required
    
    // For now, we'll simulate a local dictionary check
    await Future.delayed(Duration(milliseconds: 100));
    return _mockDictionary.contains(word.toLowerCase());
  }
  
  // Mock dictionary for demonstration
  final _mockDictionary = {
    'wonder', 'word', 'world', 'work', 'wow', 'down', 'row', 'now',
    'own', 'rod', 'worn', 'won', 'door', 'wool', 'wood', 'words',
    'wonders', 'puzzle', 'puzzles'
  };
}