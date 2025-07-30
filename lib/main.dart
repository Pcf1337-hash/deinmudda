/// Konsum Tracker Pro - Main Application Entry Point
/// 
/// CRITICAL REFACTOR: Simplified from 367 lines to ~50 lines
/// - Separated initialization logic into AppBootstrapper 
/// - Moved theme management to AppThemeManager
/// - Moved provider setup to ProviderManager
/// - Replaced singleton pattern with ServiceLocator
/// 
/// LATEST UPDATES:
/// - Cross-Platform Polishing completed for iOS/Android
/// - Platform-adaptive UI components implemented
/// - Test structure stabilized (basic tests only)
/// - Clean architecture with proper separation of concerns
/// 
/// Author: Code Quality Improvement Agent
/// Date: Latest Update - Project Stabilization Phase

import 'package:flutter/material.dart';
import 'utils/app_bootstrapper.dart';
import 'utils/provider_manager.dart';
import 'utils/app_theme_manager.dart';

/// Main application entry point
/// 
/// COMPLEXITY REDUCTION: From 367 lines to ~15 lines in main()
/// All initialization logic moved to specialized managers
void main() async {
  try {
    // Initialize the entire application
    await AppBootstrapper.initialize();
    
    // Start the app with proper provider and theme setup
    runApp(const KonsumTrackerApp());
  } catch (e) {
    // Critical startup error - log and attempt basic fallback
    print('💥 CRITICAL: App startup failed: $e');
    
    // Attempt to start with minimal fallback
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App konnte nicht gestartet werden',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fehler: $e',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Main App Widget with Provider and Theme Management
/// 
/// ARCHITECTURE FIX: Clean separation of concerns
/// - ProviderManager handles dependency injection
/// - AppThemeManager handles theme configuration
/// - Removed complex error handling (moved to AppBootstrapper)
class KonsumTrackerApp extends StatelessWidget {
  const KonsumTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Build app with providers from ServiceLocator
    return ProviderManager.buildAppWithProviders(
      child: AppThemeManager.buildMaterialApp(),
    );
  }
}