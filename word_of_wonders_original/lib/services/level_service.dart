import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/level.dart';
import '../models/word.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  List<Level> _levels = [];
  
  // Load all levels from assets
  Future<List<Level>> loadLevels() async {
    if (_levels.isNotEmpty) return _levels;
    
    try {
      // Load from a JSON file in assets
      final jsonString = await rootBundle.loadString('assets/data/levels.json');
      final data = jsonDecode(jsonString);
      
      _levels = [];
      
      // Check if the JSON structure has voyages
      if (data is List && data.isNotEmpty && data[0] is Map && data[0].containsKey('voyageId')) {
        // New format with voyages - extract levels from each voyage
        for (var voyageJson in data) {
          final levelsList = voyageJson['levels'] as List;
          for (var levelJson in levelsList) {
            _levels.add(Level.fromJson(levelJson));
          }
        }
      } else {
        // Original format - direct list of levels
        _levels = (data as List).map((json) => Level.fromJson(json)).toList();
      }
      
      return _levels;
    } catch (e) {
      print('Error loading levels: $e');
      // Return some default levels if loading fails
      return [
        Level(
          id: 1,
          letters: ['w', 'o', 'r', 'd', 's', 'n', 'e'],
          words: [
            Word(text: 'word'),
            Word(text: 'words'),
            Word(text: 'worn'),
            Word(text: 'rose'),
            Word(text: 'down'),
            Word(text: 'sore'),
            Word(text: 'nerd'),
            Word(text: 'wore'),
          ],
        ),
        Level(
          id: 2,
          letters: ['p', 'u', 'z', 'l', 'e', 's'],
          words: [
            Word(text: 'puzzle'),
            Word(text: 'puzzles'),
            Word(text: 'peel'),
            Word(text: 'plus'),
            Word(text: 'pulses'),
            Word(text: 'zeps'),
          ],
        ),
      ];
    }
  }
  
  // Get a specific level by ID
  Future<Level> getLevel(int levelId) async {
    final levels = await loadLevels();
    return levels.firstWhere(
      (level) => level.id == levelId,
      orElse: () => Level(
        id: levelId,
        letters: ['g', 'a', 'm', 'e', 'o', 'v', 'r'],
        words: [
          Word(text: 'game'),
          Word(text: 'over'),
          Word(text: 'more'),
          Word(text: 'grave'),
          Word(text: 'move'),
        ],
      ),
    );
  }
  
  // Save player progress
  Future<void> saveProgress(int levelId, int stars, int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_${levelId}_stars', stars);
    await prefs.setInt('level_${levelId}_score', score);
    
    // Update max level reached if needed
    final currentMaxLevel = prefs.getInt('max_level_reached') ?? 1;
    if (levelId + 1 > currentMaxLevel) {
      await prefs.setInt('max_level_reached', levelId + 1);
    }
  }
  
  // Get the highest unlocked level
  Future<int> getMaxUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('max_level_reached') ?? 1;
  }
  
  // Get stars for a specific level
  Future<int> getLevelStars(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_${levelId}_stars') ?? 0;
  }
}