import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_project.dart';

/// Persists the list of saved projects to local key-value storage as JSON.
///
/// Uses `shared_preferences`, which is backed by the platform's native store
/// (registry on Windows, NSUserDefaults on iOS, SharedPreferences on Android),
/// so saved projects survive an app restart.
class ProjectStore {
  static const String _key = 'saved_projects';

  /// Loads saved projects. Returns an empty list if none are stored.
  Future<List<SavedProject>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <SavedProject>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic e) =>
            SavedProject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Writes the full list of [projects], replacing whatever was stored.
  Future<void> save(List<SavedProject> projects) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = jsonEncode(
      projects.map((SavedProject p) => p.toJson()).toList(),
    );
    await prefs.setString(_key, raw);
  }
}
