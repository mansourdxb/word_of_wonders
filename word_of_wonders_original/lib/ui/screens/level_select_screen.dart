import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/level_service.dart';
import '../../models/level.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  _LevelSelectScreenState createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late Future<List<Level>> _levelsFuture;
  late Future<int> _maxUnlockedLevelFuture;
  
  @override
  void initState() {
    super.initState();
    final levelService = Provider.of<LevelService>(context, listen: false);
    _levelsFuture = levelService.loadLevels();
    _maxUnlockedLevelFuture = levelService.getMaxUnlockedLevel();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Level'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([_levelsFuture, _maxUnlockedLevelFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading levels: ${snapshot.error}'),
              );
            }
            
            final levels = snapshot.data![0] as List<Level>;
            final maxUnlockedLevel = snapshot.data![1] as int;
            
            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final isUnlocked = level.id <= maxUnlockedLevel;
                
                return FutureBuilder<int>(
                  future: Provider.of<LevelService>(context, listen: false)
                      .getLevelStars(level.id),
                  builder: (context, starsSnapshot) {
                    final stars = starsSnapshot.data ?? 0;
                    
                    return GestureDetector(
                      onTap: isUnlocked ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(level: level),
                          ),
                        );
                      } : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUnlocked ? Colors.white : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${level.id}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (isUnlocked)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (i) => 
                                  Icon(
                                    i < stars ? Icons.star : Icons.star_border,
                                    color: i < stars ? Colors.amber : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}