import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import '../services/game_sound.dart';

/// Snake: il bus mangia le fermate e si allunga. Facile: i bordi non
/// bloccano (si riappare dall'altra parte); medio e difficile: muri e più veloce.
class SnakeScreen extends StatefulWidget {
  final Difficulty difficulty;
  const SnakeScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<SnakeScreen> createState() => _SnakeScreenState();
}

class _SnakeScreenState extends State<SnakeScreen> {
  static const int n = 16;
  final _rand = Random();
  Timer? _timer;
  List<Point<int>> _snake = [];
  Point<int> _dir = const Point(1, 0);
  Point<int> _pending = const Point(1, 0);
  Point<int> _food = const Point(10, 8);
  int _score = 0;
  bool _over = false;
  bool _running = false;
  bool _newRecord = false;
  bool _revived = false;
  Offset _acc = Offset.zero;

  bool get _wrap => widget.difficulty == Difficulty.easy;
  Duration get _tick => Duration(milliseconds: const [200, 145, 105][widget.difficulty.index]);
  String get _key => 'snake_${widget.difficulty.name}';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _newGame() {
    _timer?.cancel();
    setState(() {
      _snake = [const Point(8, 8), const Point(7, 8), const Point(6, 8)];
      _dir = const Point(1, 0);
      _pending = const Point(1, 0);
      _score = 0;
      _over = false;
      _running = false;
      _newRecord = false;
      _revived = false;
      _food = _randomFood();
    });
  }

  Point<int> _randomFood() {
    while (true) {
      final p = Point(_rand.nextInt(n), _rand.nextInt(n));
      if (!_snake.contains(p)) return p;
    }
  }

  void _turn(Point<int> d) {
    if (_over) return;
    if (d.x == -_dir.x && d.y == -_dir.y) return;
    _pending = d;
    if (!_running) {
      _running = true;
      _timer = Timer.periodic(_tick, (_) => _step());
    }
  }

  Future<void> _step() async {
    if (!mounted || _over) return;
    _dir = _pending;
    var head = Point(_snake.first.x + _dir.x, _snake.first.y + _dir.y);
    if (_wrap) {
      head = Point((head.x + n) % n, (head.y + n) % n);
    } else if (head.x < 0 || head.y < 0 || head.x >= n || head.y >= n) {
      return _die();
    }
    final eat = head == _food;
    final body = eat ? _snake : _snake.sublist(0, _snake.length - 1);
    if (body.contains(head)) return _die();
    setState(() {
      _snake.insert(0, head);
      if (eat) {
        _score++;
        GameSound.instance.play(Sfx.eat);
        HapticFeedback.selectionClick();
        _food = _snake.length >= n * n ? head : _randomFood();
      } else {
        _snake.removeLast();
      }
    });
  }

  Future<void> _die() async {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    GameSound.instance.play(Sfx.thud);
    final record = _score > 0 && await GameStats.instance.submitHigh(_key, _score);
    if (!mounted) return;
    setState(() {
      _over = true;
      _running = false;
      _newRecord = record;
    });
    _offerRevive();
  }

  /// Una sola ripresa per partita: il bus riparte corto dal centro e il
  /// punteggio resta.
  Future<void> _offerRevive() async {
    if (_revived || !_over || !mounted || !RewardedOffer.available) return;
    final l = AppLocalizations.of(context)!;
    final ok = await RewardedOffer.ask(context,
        game: 'snake', action: 'revive', title: l.rewardedReviveTitle, message: l.rewardedReviveMessage);
    if (!ok || !mounted) return;
    setState(() {
      _snake = [const Point(8, 8), const Point(7, 8), const Point(6, 8)];
      _dir = const Point(1, 0);
      _pending = const Point(1, 0);
      _food = _randomFood();
      _over = false;
      _running = false;
      _newRecord = false;
      _revived = true;
    });
  }

  void _onPan(DragUpdateDetails d) {
    _acc += d.delta;
    if (_acc.distance < 14) return;
    if (_acc.dx.abs() > _acc.dy.abs()) {
      _turn(Point(_acc.dx > 0 ? 1 : -1, 0));
    } else {
      _turn(Point(0, _acc.dy > 0 ? 1 : -1));
    }
    _acc = Offset.zero;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowUp) {
      _turn(const Point(0, -1));
    } else if (k == LogicalKeyboardKey.arrowDown) {
      _turn(const Point(0, 1));
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _turn(const Point(-1, 0));
    } else if (k == LogicalKeyboardKey.arrowRight) {
      _turn(const Point(1, 0));
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.high(_key);
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: GameScaffold(
        title: l.gameSnake,
        guardBack: true,
        physics: const NeverScrollableScrollPhysics(),
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
                : Text(l.gameSnakeHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) => _acc = Offset.zero,
              onPanUpdate: _onPan,
              child: CustomPaint(
                painter: _SnakePainter(_snake, _food, scheme, _wrap),
                child: const SizedBox.expand(),
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
          GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
        ],
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final ColorScheme scheme;
  final bool wrap;
  _SnakePainter(this.snake, this.food, this.scheme, this.wrap);

  @override
  void paint(Canvas canvas, Size size) {
    const n = _SnakeScreenState.n;
    final cell = size.width / n;
    final bg = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
    canvas.drawRRect(bg, Paint()..color = scheme.surfaceContainerHighest);
    final light = Paint()..color = scheme.onSurface.withOpacity(0.05);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if ((x + y).isOdd) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), light);
      }
    }
    if (!wrap) {
      canvas.drawRRect(
          bg,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = scheme.error.withOpacity(0.6));
    }
    // fermata (cibo)
    final fc = Offset(food.x * cell + cell / 2, food.y * cell + cell / 2);
    canvas.drawCircle(fc, cell * 0.38, Paint()..color = Colors.amber.shade600);
    canvas.drawCircle(fc, cell * 0.2, Paint()..color = Colors.white);
    // bus
    for (var i = snake.length - 1; i >= 0; i--) {
      final p = snake[i];
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(p.x * cell + 1, p.y * cell + 1, cell - 2, cell - 2),
        Radius.circular(i == 0 ? cell * 0.4 : cell * 0.25),
      );
      canvas.drawRRect(r, Paint()..color = i == 0 ? const Color(0xFFD32F2F) : const Color(0xFFE57373));
    }
    if (snake.isNotEmpty) {
      final h = snake.first;
      canvas.drawCircle(Offset(h.x * cell + cell * 0.35, h.y * cell + cell * 0.38), cell * 0.1,
          Paint()..color = Colors.white);
      canvas.drawCircle(Offset(h.x * cell + cell * 0.65, h.y * cell + cell * 0.38), cell * 0.1,
          Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter old) => true;
}
