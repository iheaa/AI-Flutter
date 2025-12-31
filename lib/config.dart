import 'dart:convert';
import 'package:flutter/services.dart';

class Config {
  static Map<String, String> _env = {};

  static Future<void> load() async {
    try {
      final envString = await rootBundle.loadString('.env');
      final envLines = envString.split('\n');
      for (final line in envLines) {
        if (line.contains('=')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            _env[parts[0].trim()] = parts[1].trim();
          }
        }
      }
      print('Config loaded successfully');
    } catch (e) {
      print('Error loading config: $e');
    }
  }

  static String get(String key) {
    return _env[key] ?? '';
  }
}
