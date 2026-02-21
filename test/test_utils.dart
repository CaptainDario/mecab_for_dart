import 'dart:io';
import 'package:path/path.dart' as path;


double currentMemoryUsage() {
  return (ProcessInfo.currentRss / 1024 / 1024);
}

String currentMemoryUsageString() {
  return (ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2);
}



/// Finds the root directory of the project by looking for pubspec.yaml.
String getProjectRoot() {
  Directory current = Directory.current;
  
  // Keep going up the directory tree until we hit the system root
  while (current.path != current.parent.path) {
    final pubspecFile = File(path.join(current.path, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      return current.path;
    }
    current = current.parent;
  }
  
  throw Exception('Could not find project root! (pubspec.yaml not found)');
}

/// Helper to get the absolute path to your assets folder
String getAssetsPath() {
  return path.join(getProjectRoot(), 'assets');
}