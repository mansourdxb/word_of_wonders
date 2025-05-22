import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/home_screen.dart';
import 'config/themes.dart';
import 'services/level_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => LevelService()),
      ],
      child: MaterialApp(
        title: 'Words of Wonders',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}