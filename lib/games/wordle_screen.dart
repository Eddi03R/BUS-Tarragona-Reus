import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_common.dart';
import 'logic/wordle_logic.dart';

/// Parola del giorno: indovina la parola di 5 lettere in 6 tentativi.
/// La parola è la stessa per tutti gli utenti della stessa lingua.
class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> with TickerProviderStateMixin {
  final _rand = Random();
  final _focus = FocusNode();
  late final AnimationController _reveal =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  String _lang = 'en';
  bool _daily = true;
  String _answer = '';
  final List<String> _guesses = [];
  String _current = '';
  String? _message;
  int _revealRow = -1;
  bool _revealing = false;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    final code = Localizations.localeOf(context).languageCode;
    _lang = ['it', 'en', 'es', 'ca', 'de'].contains(code) ? code : 'en';
    _startDaily();
  }

  @override
  void dispose() {
    _focus.dispose();
    _reveal.dispose();
    _shake.dispose();
    super.dispose();
  }

  String get _prefKey => 'wordle_${_lang}_${WordleLogic.dayNumber(DateTime.now())}';

  Future<void> _startDaily() async {
    _daily = true;
    _answer = WordleLogic.dailyWord(_lang, DateTime.now());
    _guesses.clear();
    _current = '';
    _message = null;
    _revealRow = -1;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && saved.isNotEmpty) _guesses.addAll(saved.split(','));
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void _startPractice() {
    setState(() {
      _daily = false;
      _answer = WordleLogic.randomWord(_lang, _rand);
      _guesses.clear();
      _current = '';
      _message = null;
      _revealRow = -1;
    });
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _guesses.join(','));
    } catch (_) {}
  }

  bool get _solved => _guesses.isNotEmpty && _guesses.last == _answer;
  bool get _finished => _solved || _guesses.length >= WordleLogic.maxAttempts;

  void _type(String ch) {
    if (_finished || _revealing || _current.length >= WordleLogic.wordLength) return;
    setState(() {
      _message = null;
      _current += ch.toLowerCase();
    });
  }

  void _back() {
    if (_finished || _revealing || _current.isEmpty) return;
    setState(() => _current = _current.substring(0, _current.length - 1));
  }

  Future<void> _enter() async {
    if (_finished || _revealing) return;
    final l = AppLocalizations.of(context)!;
    if (_current.length < WordleLogic.wordLength) {
      setState(() => _message = l.wordleNotEnough);
      _shake.forward(from: 0);
      HapticFeedback.lightImpact();
      return;
    }
    setState(() {
      _guesses.add(_current);
      _current = '';
      _revealRow = _guesses.length - 1;
      _revealing = true;
    });
    if (_daily) _save();
    await _reveal.forward(from: 0);
    if (mounted) setState(() => _revealing = false);
  }

  Map<String, LetterState> get _keyStates {
    final m = <String, LetterState>{};
    for (final g in _guesses) {
      final ev = WordleLogic.evaluate(g, _answer);
      for (var i = 0; i < g.length; i++) {
        final cur = m[g[i]];
        if (cur == null || ev[i].index > cur.index) m[g[i]] = ev[i];
      }
    }
    return m;
  }

  Color _stateColor(LetterState s) => switch (s) {
        LetterState.correct => const Color(0xFF43A047),
        LetterState.present => const Color(0xFFE0B100),
        LetterState.absent => const Color(0xFF6E7C7A),
      };

  Future<void> _share(AppLocalizations l) async {
    final rows = _guesses
        .map((g) => WordleLogic.evaluate(g, _answer)
            .map((s) => switch (s) {
                  LetterState.correct => '🟩',
                  LetterState.present => '🟨',
                  LetterState.absent => '⬛',
                })
            .join())
        .join('\n');
    final score = _solved ? '${_guesses.length}/${WordleLogic.maxAttempts}' : 'X/${WordleLogic.maxAttempts}';
    await Share.share('ErasBus Tarragona · ${l.gameWordle} #${WordleLogic.dayNumber(DateTime.now())} $score\n$rows');
  }

  // ------------------------------------------------------------------------ UI
  Widget _tile(int row, int col, double size) {
    final scheme = Theme.of(context).colorScheme;
    String letter = '';
    LetterState? state;
    if (row < _guesses.length) {
      letter = _guesses[row][col];
      state = WordleLogic.evaluate(_guesses[row], _answer)[col];
    } else if (row == _guesses.length && col < _current.length) {
      letter = _current[col];
    }
    var colored = state != null;
    var scaleY = 1.0;
    if (row == _revealRow && _revealing) {
      final p = ((_reveal.value - col * 0.14) / 0.42).clamp(0.0, 1.0);
      colored = p > 0.5;
      scaleY = p < 0.5 ? 1 - 2 * p : 2 * p - 1;
      if (p == 0) colored = false;
    }
    return Transform.scale(
      scaleY: max(scaleY, 0.02),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colored ? _stateColor(state!) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colored
                ? Colors.transparent
                : (letter.isNotEmpty ? scheme.onSurface : scheme.outlineVariant),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(letter.toUpperCase(),
            style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w900,
                color: colored ? Colors.white : scheme.onSurface)),
      ),
    );
  }

  Widget _key(String label, {double flex = 1, VoidCallback? onTap, LetterState? state, IconData? icon}) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: (flex * 10).round(),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: state != null ? _stateColor(state) : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              height: 46,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 20, color: state != null ? Colors.white : scheme.onSurface)
                    : Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: label.length > 1 ? 12 : 16,
                            color: state != null ? Colors.white : scheme.onSurface)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final tile = min((min(width, 520) - 40 - 4 * 6) / 5, 58.0);
    final keys = _keyStates;
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    final showResult = _finished && !_revealing;

    return KeyboardListener(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        if (e.logicalKey == LogicalKeyboardKey.enter) {
          _enter();
        } else if (e.logicalKey == LogicalKeyboardKey.backspace) {
          _back();
        } else {
          final ch = e.character;
          if (ch != null && RegExp(r'^[a-zA-Z]$').hasMatch(ch)) _type(ch);
        }
      },
      child: GameScaffold(
        title: l.gameWordle,
        celebrate: showResult && _solved,
        children: [
          Text(_daily ? l.wordleToday : l.wordlePractice,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
          StatusSlot(
            child: showResult
                ? ResultBanner(
                    key: ValueKey('res-${_guesses.length}-$_solved'),
                    text: _solved ? l.gameYouWin : l.wordleAnswer(_answer.toUpperCase()),
                    kind: _solved ? ResultKind.win : ResultKind.lose,
                  )
                : Text(_message ?? l.gameWordleHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: _message != null ? FontWeight.w700 : FontWeight.w400,
                        color: _message != null ? scheme.error : scheme.onSurfaceVariant)),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_reveal, _shake]),
            builder: (context, _) => Column(
              children: [
                for (var r = 0; r < WordleLogic.maxAttempts; r++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Transform.translate(
                      offset: Offset(
                          r == _guesses.length ? sin(_shake.value * pi * 6) * (1 - _shake.value) * 10 : 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var c = 0; c < WordleLogic.wordLength; c++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: _tile(r, c, tile),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < rows.length; i++)
            Row(
              children: [
                if (i == 2) _key('', flex: 1.5, icon: Icons.keyboard_return_rounded, onTap: _enter),
                if (i == 1) const Spacer(flex: 5),
                for (final ch in rows[i].split(''))
                  _key(ch, state: keys[ch.toLowerCase()], onTap: () => _type(ch)),
                if (i == 1) const Spacer(flex: 5),
                if (i == 2) _key('', flex: 1.5, icon: Icons.backspace_outlined, onTap: _back),
              ],
            ),
          const SizedBox(height: 14),
          if (showResult && _daily) ...[
            GameButton(
                onPressed: () => _share(l), icon: Icons.ios_share_rounded, label: l.wordleShare),
            const SizedBox(height: 10),
            Text(l.wordleComeBack,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 10),
          ],
          if (showResult || !_daily)
            GameButton(
              primary: false,
              onPressed: _startPractice,
              icon: Icons.casino_rounded,
              label: l.wordlePractice,
            ),
          if (!_daily) ...[
            const SizedBox(height: 10),
            GameButton(
              primary: false,
              onPressed: _startDaily,
              icon: Icons.today_rounded,
              label: l.wordleToday,
            ),
          ],
        ],
      ),
    );
  }
}
