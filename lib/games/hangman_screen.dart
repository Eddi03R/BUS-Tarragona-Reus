import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/hangman_logic.dart';
import '../services/game_sound.dart';

/// Impiccato: indovina la parola scegliendo le lettere; ogni errore aggiunge
/// un pezzo al disegno. Difficoltà = errori consentiti (8 / 7 / 6), lunghezza
/// delle parole e tasti sbagliati già cancellati (molti / pochi / nessuno).
class HangmanScreen extends StatefulWidget {
  final Difficulty difficulty;
  const HangmanScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<HangmanScreen> createState() => HangmanScreenState();
}

class HangmanScreenState extends State<HangmanScreen> with SingleTickerProviderStateMixin {
  final _rand = Random();
  late final AnimationController _draw =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450), value: 1);
  late String _word;
  final Set<String> _guessed = {};
  Set<String> _gone = {}; // tasti sbagliati già cancellati
  static String _lastWord = '';
  bool _recorded = false;

  @visibleForTesting
  String get word => _word;

  int get _d => widget.difficulty.index;
  int get _maxWrong => HangmanLogic.maxWrong(_d);
  int get _wrong => _guessed.where((c) => !_word.contains(c)).length;
  bool get _won => HangmanLogic.won(_word, _guessed);
  bool get _lost => _wrong >= _maxWrong;

  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ready) {
      _ready = true;
      _word = _newWord(); // la lingua si legge dal contesto: non si può in initState
      _gone = HangmanLogic.eliminated(_word, _d, _rand);
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  String _newWord() {
    final lang = Localizations.localeOf(context).languageCode;
    var w = HangmanLogic.pick(lang, _d, _rand);
    for (var i = 0; i < 5 && w == _lastWord; i++) {
      w = HangmanLogic.pick(lang, _d, _rand);
    }
    return _lastWord = w;
  }

  void _newGame() {
    final w = _newWord();
    _draw.value = 1;
    setState(() {
      _word = w;
      _gone = HangmanLogic.eliminated(w, _d, _rand);
      _guessed.clear();
      _recorded = false;
    });
  }

  Future<void> _guess(String c) async {
    if (_won || _lost || _guessed.contains(c) || _gone.contains(c)) return;
    final hit = _word.contains(c);
    GameSound.instance.play(hit ? Sfx.letterOk : Sfx.letterNo);
    setState(() => _guessed.add(c));
    if (!hit) _draw.forward(from: 0);
    if (_won && !_recorded) {
      _recorded = true;
      await GameStats.instance.setValue('hangman_wins', GameStats.instance.value('hangman_wins') + 1);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final over = _won || _lost;
    final parts = ((_wrong * 8) / _maxWrong).ceil().clamp(0, 8);
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return GameScaffold(
      title: l.gameHangman,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(l.hmMistakes(_wrong, _maxWrong),
                  overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(l.hmWins(GameStats.instance.value('hangman_wins'))),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(key: const ValueKey('hw'), text: l.gameYouWin, kind: ResultKind.win)
              : _lost
                  ? ResultBanner(key: const ValueKey('hl'), text: l.gameYouLose, kind: ResultKind.lose)
                  : Text(l.gameHangmanHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        // scena: tramonto, terra e forca
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD9A8), Color(0xFFFFB27A)],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 176,
                child: CustomPaint(
                  painter: _GallowsPainter(parts, _draw),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 8,
                children: [
                  for (final c in _word.split(''))
                    Container(
                      width: 30,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.88),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Color(0x2E000000), offset: Offset(0, 3))],
                      ),
                      child: Text(
                        _guessed.contains(c) || _lost ? c : '',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: !_guessed.contains(c) && _lost ? const Color(0xFFC62828) : const Color(0xFF3A2314),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 8,
          children: [
            for (final c in letters.split(''))
              _KeyCap(
                key: ValueKey('key-$c'),
                letter: c,
                state: _gone.contains(c)
                    ? _KeyState.gone
                    : _guessed.contains(c)
                        ? (_word.contains(c) ? _KeyState.ok : _KeyState.no)
                        : _KeyState.normal,
                onTap: over ? null : () => _guess(c),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GameButton(primary: over, onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

enum _KeyState { normal, ok, no, gone }

class _KeyCap extends StatefulWidget {
  final String letter;
  final _KeyState state;
  final VoidCallback? onTap;
  const _KeyCap({super.key, required this.letter, required this.state, this.onTap});

  @override
  State<_KeyCap> createState() => _KeyCapState();
}

class _KeyCapState extends State<_KeyCap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final (bg, edge, fg) = switch (s) {
      _KeyState.normal => (const Color(0xFFFFF6E8), const Color(0xFFD9B98F), const Color(0xFF4A2B17)),
      _KeyState.ok => (const Color(0xFF4CB768), const Color(0xFF2F8A49), Colors.white),
      _KeyState.no => (const Color(0xFFE0605A), const Color(0xFFA93B36), Colors.white),
      _KeyState.gone => (const Color(0xFFCDBBA5), const Color(0xFFCDBBA5), const Color(0xFF9D8A75)),
    };
    final enabled = s == _KeyState.normal && widget.onTap != null;
    Widget cap = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      transform: Matrix4.translationValues(0, _down ? 2 : 0, 0),
      width: 34,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        boxShadow: s == _KeyState.gone || _down ? null : [BoxShadow(color: edge, offset: const Offset(0, 3))],
      ),
      child: Text(
        widget.letter,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: fg,
          decoration: s == _KeyState.gone ? TextDecoration.lineThrough : null,
        ),
      ),
    );
    if (s == _KeyState.no) {
      // scossa quando la lettera è sbagliata
      cap = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        builder: (context, t, child) => Transform.translate(offset: Offset(sin(t * pi * 4) * (1 - t) * 5, 0), child: child),
        child: cap,
      );
    }
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: enabled ? widget.onTap : null,
      child: cap,
    );
  }
}

/// Forca e omino: [parts] pezzi su 8; l'ultimo si disegna piano piano (valore [anim] 0..1).
class _GallowsPainter extends CustomPainter {
  final int parts;
  final Animation<double> anim;
  _GallowsPainter(this.parts, this.anim) : super(repaint: anim);

  static final _defs = <(Path, Color, double)>[
    (Path()..moveTo(12, 162)..lineTo(110, 162)..moveTo(26, 162)..lineTo(40, 148)..moveTo(96, 162)..lineTo(82, 148), const Color(0xFF4A2B17), 8),
    (Path()..moveTo(40, 160)..lineTo(40, 10), const Color(0xFF8A5530), 9),
    (Path()..moveTo(36, 12)..lineTo(132, 12)..moveTo(40, 34)..lineTo(66, 12), const Color(0xFF8A5530), 9),
    (Path()..moveTo(126, 14)..lineTo(126, 38), const Color(0xFFC9A46B), 4),
    (Path()..addOval(Rect.fromCircle(center: const Offset(126, 52), radius: 15)), const Color(0xFF3A2314), 5),
    (Path()..moveTo(126, 67)..lineTo(126, 112), const Color(0xFFD1493F), 9),
    (Path()..moveTo(126, 80)..lineTo(104, 100)..moveTo(126, 80)..lineTo(148, 100), const Color(0xFFD1493F), 7),
    (Path()..moveTo(126, 112)..lineTo(108, 144)..moveTo(126, 112)..lineTo(144, 144), const Color(0xFF2F5F9E), 8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width / 200, size.height / 170);
    canvas.save();
    canvas.translate((size.width - 200 * s) / 2, (size.height - 170 * s) / 2);
    canvas.scale(s);
    // sole e collina
    canvas.drawCircle(const Offset(168, 40), 18, Paint()..color = const Color(0x77FFF3C4));
    canvas.drawOval(const Rect.fromLTWH(-10, 150, 220, 46), Paint()..color = const Color(0xFF6B9A4A));
    canvas.drawOval(const Rect.fromLTWH(-10, 150, 220, 46), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF8DBB63));
    for (var i = 0; i < parts && i < _defs.length; i++) {
      final (path, color, width) = _defs[i];
      final t = i == parts - 1 ? Curves.easeOut.transform(anim.value) : 1.0;
      if (i == 4 && t >= 1) {
        canvas.drawPath(path, Paint()..color = const Color(0xFFFFD9B0));
      }
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
      for (final m in path.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * t), paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GallowsPainter old) => old.parts != parts;
}
