import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/hangman_logic.dart';
import '../services/game_sound.dart';

/// Impiccato: indovina la parola scegliendo le lettere; ogni errore aggiunge
/// un pezzo al disegno. Difficoltà = errori consentiti (8 / 7 / 6) e lunghezza delle parole.
class HangmanScreen extends StatefulWidget {
  final Difficulty difficulty;
  const HangmanScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  final _rand = Random();
  late String _word;
  final Set<String> _guessed = {};
  static String _lastWord = '';
  bool _recorded = false;

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
    }
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
    setState(() {
      _word = w;
      _guessed.clear();
      _recorded = false;
    });
  }

  Future<void> _guess(String c) async {
    if (_won || _lost || _guessed.contains(c)) return;
    final hit = _word.contains(c);
    GameSound.instance.play(hit ? Sfx.correct : Sfx.wrong);
    setState(() => _guessed.add(c));
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
        SizedBox(
          height: 170,
          child: CustomPaint(
            painter: _GallowsPainter(((_wrong * 8) / _maxWrong).ceil().clamp(0, 8), scheme.onSurface),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 8,
          children: [
            for (final c in _word.split(''))
              Container(
                width: 26,
                padding: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: scheme.onSurface, width: 2))),
                child: Text(
                  _guessed.contains(c) || _lost ? c : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: !_guessed.contains(c) && _lost ? scheme.error : scheme.onSurface),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in letters.split(''))
              SizedBox(
                width: 38,
                height: 42,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: _guessed.contains(c)
                        ? (_word.contains(c) ? Colors.green.shade600 : scheme.errorContainer)
                        : null,
                  ),
                  onPressed: over || _guessed.contains(c) ? null : () => _guess(c),
                  child: Text(c,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _guessed.contains(c) && _word.contains(c) ? Colors.white : null)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GameButton(primary: over, onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

/// Forca e omino: [parts] pezzi su 8 (base, palo, trave, corda, testa, corpo, braccia, gambe).
class _GallowsPainter extends CustomPainter {
  final int parts;
  final Color color;
  _GallowsPainter(this.parts, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    final cx = w / 2;
    final left = cx - 60, top = 8.0, base = h - 6;
    if (parts >= 1) canvas.drawLine(Offset(left - 25, base), Offset(left + 60, base), p);
    if (parts >= 2) canvas.drawLine(Offset(left, base), Offset(left, top), p);
    if (parts >= 3) canvas.drawLine(Offset(left, top), Offset(left + 90, top), p);
    if (parts >= 4) canvas.drawLine(Offset(left + 90, top), Offset(left + 90, top + 26), p);
    final hx = left + 90, hy = top + 26 + 16;
    if (parts >= 5) canvas.drawCircle(Offset(hx, hy), 16, p);
    if (parts >= 6) canvas.drawLine(Offset(hx, hy + 16), Offset(hx, hy + 70), p);
    if (parts >= 7) {
      canvas.drawLine(Offset(hx, hy + 30), Offset(hx - 22, hy + 52), p);
      canvas.drawLine(Offset(hx, hy + 30), Offset(hx + 22, hy + 52), p);
    }
    if (parts >= 8) {
      canvas.drawLine(Offset(hx, hy + 70), Offset(hx - 20, hy + 100), p);
      canvas.drawLine(Offset(hx, hy + 70), Offset(hx + 20, hy + 100), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GallowsPainter old) => old.parts != parts || old.color != color;
}
