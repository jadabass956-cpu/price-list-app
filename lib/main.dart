import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/products_list_screen.dart';

void main() => runApp(const PriceListApp());

class PriceListApp extends StatelessWidget {
  const PriceListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قائمة الأسعار',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
      ),
      home: const ProductsListScreen(),
    );
  }
}
