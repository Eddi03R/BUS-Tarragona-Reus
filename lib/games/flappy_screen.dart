import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';

class _Pipe {
  double x;
  final double gapY;
  bool scored = false;
  _Pipe(this.x, this.gapY);
}

/// Bus volante: tocca per far saltare il bus tra i palazzi.
/// Mondo logico 300×420, scalato alla dimensione dello schermo.
class FlappyScreen extends StatefulWidget {
  final Difficulty difficulty;
  const FlappyScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<FlappyScreen> createState() => _FlappyScreenState();
}

class _FlappyScreenState extends State<FlappyScreen> with SingleTickerProviderStateMixin {
  static const double w = 300, h = 420, busX = 70, pipeW = 54, gravity = 900, flap = -320;
  final _rand = Random();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _y = h / 2;
  double _vy = 0;
  final List<_Pipe> _pipes = [];
  int _score = 0;
  bool _started = false;
  bool _over = false;
  bool _newRecord = false;
  bool _revived = false;

  double get _speed => const [95.0, 115.0, 135.0][widget.difficulty.index];
  double get _gap => const [150.0, 128.0, 110.0][widget.difficulty.index];
  String get _key => 'flappy_${widget.difficulty.name}';

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _reset();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _reset() {
    _ticker.stop();
    _last = Duration.zero;
    setState(() {
      _y = h / 2;
      _vy = 0;
      _pipes.clear();
      _score = 0;
      _started = false;
      _over = false;
      _newRecord = false;
      _revived = false;
      _pipes
        ..add(_Pipe(w + 40, _randGap()))
        ..add(_Pipe(w + 40 + 175, _randGap()));
    });
  }

  /// Una sola ripresa per partita: il bus torna al centro, il punteggio resta
  /// e si riparte al primo tocco.
  Future<void> _offerRevive() async {
    if (_revived || !_over || !mounted || !RewardedOffer.available) return;
    final l = AppLocalizations.of(context)!;
    final ok = await RewardedOffer.ask(context,
        game: 'flappy', action: 'revive', title: l.rewardedReviveTitle, message: l.rewardedReviveMessage);
    if (!ok || !mounted) return;
    _ticker.stop();
    _last = Duration.zero;
    setState(() {
      _y = h / 2;
      _vy = 0;
      _pipes
        ..clear()
        ..add(_Pipe(w + 40, _randGap()))
        ..add(_Pipe(w + 40 + 175, _randGap()));
      _started = false;
      _over = false;
      _newRecord = false;
      _revived = true;
    });
  }

  double _randGap() => 70 + _gap / 2 + _rand.nextDouble() * (h - 140 - _gap);

  void _tapScreen() {
    if (_over) return;
    if (!_started) {
      _started = true;
      _ticker.start();
    }
    _vy = flap;
    HapticFeedback.selectionClick();
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.04);
    _last = elapsed;
    if (_over) return;
    _vy += gravity * dt;
    _y += _vy * dt;
    for (final p in _pipes) {
      p.x -= _speed * dt;
      if (!p.scored && p.x + pipeW < busX - 17) {
        p.scored = true;
        _score++;
      }
    }
    if (_pipes.isNotEmpty && _pipes.first.x < -pipeW) {
      _pipes.removeAt(0);
      _pipes.add(_Pipe(_pipes.last.x + 175, _randGap()));
    }
    // collisioni (bus 34×20)
    const bw = 17.0, bh = 10.0;
    var hit = _y - bh < 0 || _y + bh > h - 24;
    for (final p in _pipes) {
      final overlapX = busX + bw > p.x && busX - bw < p.x + pipeW;
      if (overlapX && (_y - bh < p.gapY - _gap / 2 || _y + bh > p.gapY + _gap / 2)) hit = true;
    }
    if (hit) {
      _end();
    } else {
      setState(() {});
    }
  }

  Future<void> _end() async {
    _ticker.stop();
    HapticFeedback.heavyImpact();
    final record = _score > 0 && await GameStats.instance.submitHigh(_key, _score);
    if (!mounted) return;
    setState(() {
      _over = true;
      _newRecord = record;
    });
    _offerRevive();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.high(_key);
    return GameScaffold(
      title: l.gameFlappy,
      guardBack: true,
      // Durante il volo la pagina non scorre; a partita finita sì (i pulsanti restano raggiungibili).
      physics: _over ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.gameScore(_score),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(best == null ? l.gameNoRecord : l.gameBestScore(best)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _over
              ? ResultBanner(
                  key: ValueKey('over-$_score'),
                  text: _newRecord ? '${l.gameOver} 🏆' : l.gameOver,
                  kind: ResultKind.lose,
                )
              : Text(l.gameFlappyHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        AspectRatio(
          aspectRatio: w / h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _tapScreen(),
              child: CustomPaint(
                painter: _FlappyPainter(_y, _vy, List.of(_pipes.map((p) => (p.x, p.gapY))), _gap),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_over && !_revived && RewardedOffer.available) ...[
          HelpButton(
              freeIcon: Icons.favorite_rounded,
              label: l.rewardedReviveButton,
              onPressed: _offerRevive),
          const SizedBox(height: 10),
        ],
        GameButton(onPressed: _reset, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

class _FlappyPainter extends CustomPainter {
  final double y, vy, gap;
  final List<(double, double)> pipes;
  _FlappyPainter(this.y, this.vy, this.pipes, this.gap);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / _FlappyScreenState.w;
    canvas.scale(s);
    const w = _FlappyScreenState.w, h = _FlappyScreenState.h;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
        ).createShader(const Rect.fromLTWH(0, 0, w, h)),
    );
    // palazzi
    for (final (x, gapY) in pipes) {
      final top = Rect.fromLTWH(x, 0, _FlappyScreenState.pipeW, gapY - gap / 2);
      final bottom = Rect.fromLTWH(x, gapY + gap / 2, _FlappyScreenState.pipeW, h - (gapY + gap / 2));
      for (final r in [top, bottom]) {
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)),
            Paint()..color = const Color(0xFF8D6E63));
        final win = Paint()..color = const Color(0xFFFFE082);
        for (var wy = r.top + 10; wy < r.bottom - 10; wy += 22) {
          canvas.drawRect(Rect.fromLTWH(r.left + 10, wy, 10, 10), win);
          canvas.drawRect(Rect.fromLTWH(r.left + 32, wy, 10, 10), win);
        }
      }
    }
    // terra
    canvas.drawRect(const Rect.fromLTWH(0, h - 24, w, 24), Paint()..color = const Color(0xFF616161));
    canvas.drawRect(const Rect.fromLTWH(0, h - 24, w, 4), Paint()..color = const Color(0xFFFFC107));
    // bus
    canvas.save();
    canvas.translate(_FlappyScreenState.busX, y);
    canvas.rotate((vy / 700).clamp(-0.5, 0.6));
    final body = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-17, -10, 34, 20), const Radius.circular(6));
    canvas.drawRRect(body, Paint()..color = const Color(0xFFD32F2F));
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(-13 + i * 9.0, -6, 7, 6), Paint()..color = Colors.white);
    }
    canvas.drawCircle(const Offset(-8, 10), 4, Paint()..color = Colors.black87);
    canvas.drawCircle(const Offset(8, 10), 4, Paint()..color = Colors.black87);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlappyPainter old) => true;
}
