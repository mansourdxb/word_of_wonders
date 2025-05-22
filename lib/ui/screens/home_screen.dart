import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/level_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/Dubai.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Overlay elements
          SafeArea(
            child: Column(
              children: [
                // Top bar with coins and settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Coins display
                      Row(
                        children: [
                          // Green coins
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Image.asset('assets/icons/diamond.png', height: 24),
                                SizedBox(width: 5),
                                Text('50', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          // Blue coins
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Image.asset('assets/icons/blue_word.png', height: 24),
                                SizedBox(width: 5),
                                Text('10', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Settings button
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
                
                Spacer(),
                
                // Voyage circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white30,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '5',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'VOYAGE',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      // Loading circle indicator
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          value: 0.3,
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          backgroundColor: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Level button
                GestureDetector(
                  onTap: () async {
                    final levelService = Provider.of<LevelService>(context, listen: false);
                    final level = await levelService.getLevel(6);
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(level: level),
                      ),
                    );
                  },
                  child: Container(
                    width: 220,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      'LEVEL 6',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                
                Spacer(),
                
                // Bottom bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile button
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      
                      // Timer
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/icons/timer.png', height: 24),
                            SizedBox(width: 5),
                            Text('14:38:04', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}