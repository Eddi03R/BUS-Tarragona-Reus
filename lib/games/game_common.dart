import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Difficulty { easy, medium, hard }

String difficultyLabel(AppLocalizations l, Difficulty d) {
  switch (d) {
    case Difficulty.easy:
      return l.difficultyEasy;
    case Difficulty.medium:
      return l.difficultyMedium;
    case Difficulty.hard:
      return l.difficultyHard;
  }
}

/// Millisecondi → "m:ss".
String fmtTime(int ms) {
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Record e progressi dei giochi, salvati sul dispositivo.
class GameStats extends ChangeNotifier {
  GameStats._();
  static final GameStats instance = GameStats._();

  static const _bestPrefix = 'game_best_';
  static const _valuePrefix = 'game_val_';
  final Map<String, int> _best = {};
  final Map<String, int> _values = {};

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys()) {
        if (k.startsWith(_bestPrefix)) {
          _best[k.substring(_bestPrefix.length)] = prefs.getInt(k) ?? 0;
        } else if (k.startsWith(_valuePrefix)) {
          _values[k.substring(_valuePrefix.length)] = prefs.getInt(k) ?? 0;
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Record (più basso = meglio, es. tempo o mosse).
  int? best(String key) => _best[key];

  /// Salva se è un nuovo record; restituisce true in quel caso.
  Future<bool> submitBest(String key, int value) async {
    final old = _best[key];
    if (old != null && old <= value) return false;
    _best[key] = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_bestPrefix$key', value);
    } catch (_) {}
    return true;
  }

  int value(String key, [int fallback = 0]) => _values[key] ?? fallback;

  Future<void> setValue(String key, int value) async {
    _values[key] = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_valuePrefix$key', value);
    } catch (_) {}
  }
}

/// Selettore di difficoltà (Facile / Medio / Difficile).
class DifficultyChips extends StatelessWidget {
  final Difficulty value;
  final ValueChanged<Difficulty> onChanged;
  const DifficultyChips({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      children: [
        for (final d in Difficulty.values)
          ChoiceChip(
            label: Text(difficultyLabel(l, d)),
            selected: value == d,
            onSelected: (_) => onChanged(d),
          ),
      ],
    );
  }
}

/// Struttura comune delle schermate di gioco.
/// Senza l'effetto "elastico" di fine scorrimento, e con [physics] per
/// bloccare lo scroll mentre si trascina sul campo di gioco.
class GameScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final ScrollPhysics? physics;
  const GameScaffold({
    super.key,
    required this.title,
    required this.children,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: ListView(
                physics: physics ?? const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
