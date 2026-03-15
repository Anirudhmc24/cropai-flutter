import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/price_trend_screen.dart';
import 'providers/crop_provider.dart';

void main() {
  runApp(const CropAIApp());
}

class CropAIApp extends StatelessWidget {
  const CropAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CropProvider()),
      ],
      child: MaterialApp(
        title: 'CropAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/recommendations': (ctx) => const RecommendationScreen(),
          '/price-trend':     (ctx) => const PriceTrendScreen(),
        },
      ),
    );
  }
}