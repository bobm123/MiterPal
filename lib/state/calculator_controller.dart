import 'package:flutter/material.dart';

import '../models/compound_miter.dart';
import '../models/saved_project.dart';
import '../services/project_store.dart';
import '../services/settings_store.dart';

/// Holds the app's input state and derives the [MiterResult]. A plain
/// [ChangeNotifier] so the UI can listen without any state-management package.
class CalculatorController extends ChangeNotifier {
  CalculatorController({ProjectStore? store, SettingsStore? settings})
      : _store = store ?? ProjectStore(),
        _settings = settings ?? SettingsStore() {
    _loadSaved();
    _loadSettings();
  }

  final ProjectStore _store;
  final SettingsStore _settings;

  // Defaults per DECISIONS.md: square box, S = 10°.
  int _n = 4;
  double _sideAngle = 10.0;

  bool _exactPrecision = false; // false = round to 0.5°
  bool _showAdvanced = false; // hide dihedral D and complement M' by default
  ThemeMode _themeMode = ThemeMode.system;

  final List<SavedProject> _saved = <SavedProject>[];

  static const int minSides = 3;

  /// Physical limit: a side at +/-90 degrees is horizontal, so anything at or
  /// beyond that has no meaningful compound-miter solution.
  static const double maxSideAngle = 89.0;

  int get n => _n;
  double get sideAngle => _sideAngle;
  bool get exactPrecision => _exactPrecision;
  bool get showAdvanced => _showAdvanced;
  ThemeMode get themeMode => _themeMode;
  List<SavedProject> get saved => List<SavedProject>.unmodifiable(_saved);

  /// The current calculation.
  MiterResult get result => computeCompoundMiter(_n, _sideAngle);

  void setN(int value) {
    final int clamped = value < minSides ? minSides : value;
    if (clamped != _n) {
      _n = clamped;
      notifyListeners();
    }
  }

  void incrementN() => setN(_n + 1);
  void decrementN() => setN(_n - 1);

  void setSideAngle(double value) {
    final double clamped =
        value.clamp(-maxSideAngle, maxSideAngle).toDouble();
    if (clamped != _sideAngle) {
      _sideAngle = clamped;
      notifyListeners();
    }
  }

  void setExactPrecision(bool value) {
    if (value != _exactPrecision) {
      _exactPrecision = value;
      notifyListeners();
    }
  }

  void setShowAdvanced(bool value) {
    if (value != _showAdvanced) {
      _showAdvanced = value;
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (mode != _themeMode) {
      _themeMode = mode;
      notifyListeners();
      _settings.saveThemeMode(mode);
    }
  }

  Future<void> _loadSettings() async {
    _themeMode = await _settings.loadThemeMode();
    notifyListeners();
  }

  // --- Saved projects (persisted to disk via ProjectStore) ---

  Future<void> _loadSaved() async {
    final List<SavedProject> loaded = await _store.load();
    _saved
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  void saveProject(String name) {
    _saved.add(SavedProject(name: name, n: _n, sideAngle: _sideAngle));
    notifyListeners();
    _persist();
  }

  void loadProject(SavedProject project) {
    // Route through the setters so stored values are clamped to legal ranges.
    setN