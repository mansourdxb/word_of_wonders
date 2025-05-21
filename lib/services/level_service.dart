import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/level.dart';
import '../models/word.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  List<Level> _levels = [];
  List<Map<String, dynamic>> _voyages = [];
  
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
        _voyages = List<Map<String, dynamic>>.from(data);
        
        for (var voyageJson in _voyages) {
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
  
  // Get all voyages
  Future<List<Map<String, dynamic>>> getVoyages() async {
    await loadLevels(); // Make sure voyages are loaded
    return _voyages;
  }
  
  // Get current voyage ID
  Future<int> getCurrentVoyageId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('current_voyage_id') ?? 1;
  }
  
  // Get current voyage progress (0-100%)
  Future<double> getVoyageProgress(int voyageId) async {
    await loadLevels();
    
    // Find voyage
    final voyageData = _voyages.firstWhere(
      (v) => v['voyageId'] == voyageId, 
      orElse: () => {'levels': []}
    );
    
    // Get voyage levels
    final voyageLevels = (voyageData['levels'] as List?)?.length ?? 0;
    if (voyageLevels == 0) return 0.0;
    
    // Count completed levels in voyage
    int completedLevels = 0;
    final levelIds = (voyageData['levels'] as List?)?.map((l) => l['id'] as int).toList() ?? [];
    
    for (final levelId in levelIds) {
      final stars = await getLevelStars(levelId);
      if (stars > 0) completedLevels++;
    }
    
    return completedLevels / voyageLevels;
  }
  
  // Get coins
  Future<int> getGreenCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('diamond') ?? 50;
  }
  
  Future<int> getBlueCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('blue_word') ?? 10;
  }
  
  // Add coins
  Future<void> addGreenCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('diamond') ?? 50;
    await prefs.setInt('diamond', current + amount);
  }
  
  Future<void> addBlueCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('blue_word') ?? 10;
    await prefs.setInt('blue_word', current + amount);
  }
  
  // Get remaining time for daily bonus
  Future<Duration> getRemainingBonusTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBonusTime = prefs.getInt('last_bonus_time') ?? 0;
    
    // Convert to DateTime
    final lastBonusDateTime = DateTime.fromMillisecondsSinceEpoch(lastBonusTime);
    final nextBonusDateTime = lastBonusDateTime.add(Duration(hours: 24));
    
    // Calculate remaining time
    final now = DateTime.now();
    if (now.isAfter(nextBonusDateTime)) {
      return Duration.zero; // Bonus is available
    }
    
    return nextBonusDateTime.difference(now);
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
    
    // Add coins based on stars
    await addGreenCoins(stars * 5);
    if (stars == 3) await addBlueCoins(1);
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