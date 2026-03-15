import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/price_trend_screen.dart';
import 'providers/crop_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CropAIApp());
}

class CropAIApp extends StatelessWidget {
  const CropAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
      ],
      child: MaterialApp(
        title: 'CropAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
        routes: {
          '/recommendations': (ctx) => const RecommendationScreen(),
          '/price-trend':     (ctx) => const PriceTrendScreen(),
        },
      ),
    );
  }
}