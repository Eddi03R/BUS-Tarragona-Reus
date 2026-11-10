import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Punteggio massimo (più alto = meglio, es. punti). True se è un nuovo record.
  Future<bool> submitHigh(String key, int value) async {
    final old = _values['high_$key'];
    if (old != null && old >= value) return false;
    await setValue('high_$key', value);
    return true;
  }

  int? high(String key) => _values['high_$key'];

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

/// Bottoni dei giochi: stesse dimensioni degli altri pulsanti dell'app
/// (larghezza piena, altezza 16+16, angoli 16, testo 16 semibold).
class GameButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  const GameButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    const padding = EdgeInsets.symmetric(vertical: 16, horizontal: 12);
    const text = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    // Icona + testo in un Row centrato: con etichette lunghe (a capo su più
    // righe) l'icona resta vicina al testo invece di staccarsi sul bordo.
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    return SizedBox(
      width: double.infinity,
      child: primary
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(padding: padding),
              onPressed: onPressed,
              child: content,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(padding: padding, shape: shape, textStyle: text),
              onPressed: onPressed,
              child: content,
            ),
    );
  }
}

enum ResultKind { win, lose, neutral }

/// Risultato di una partita: compare con una piccola animazione
/// (vittoria: rimbalzo, sconfitta: scossa). Usa una [key] diversa per ripeterla.
class ResultBanner extends StatelessWidget {
  final String text;
  final ResultKind kind;
  const ResultBanner({super.key, required this.text, required this.kind});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (kind) {
      ResultKind.win => (Colors.green.shade600, Colors.white, Icons.emoji_events_rounded),
      ResultKind.lose => (Colors.red.shade600, Colors.white, Icons.sentiment_dissatisfied_rounded),
      ResultKind.neutral => (scheme.secondaryContainer, scheme.onSecondaryContainer, Icons.handshake_rounded),
    };
    final win = kind == ResultKind.win;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: win ? 900 : 650),
      curve: win ? Curves.elasticOut : Curves.easeOut,
      builder: (context, t, child) {
        final shake = kind == ResultKind.lose ? sin(t * pi * 8) * (1 - t) * 14 : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: Transform.scale(
            scale: win ? 0.4 + 0.6 * t : 0.85 + 0.15 * t,
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 10),
            Flexible(
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spazio di altezza fissa per messaggi e risultati: così, quando compare il
/// riquadro di vittoria o sconfitta, l'area di gioco sotto non si sposta.
class StatusSlot extends StatelessWidget {
  final Widget child;
  const StatusSlot({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 68, child: Center(child: child));
}

/// Coriandoli che cadono per ~3 secondi (compaiono quando si vince).
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _Piece {
  final double x, delay, speed, size, sway, spin;
  final Color color;
  const _Piece(this.x, this.delay, this.speed, this.size, this.sway, this.spin, this.color);
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..forward();
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    final r = Random();
    const colors = [
      Colors.red, Colors.amber, Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.pink,
    ];
    _pieces = List.generate(
      70,
      (_) => _Piece(
        r.nextDouble(),
        r.nextDouble() * 0.35,
        0.8 + r.nextDouble() * 0.5,
        6 + r.nextDouble() * 7,
        1 + r.nextDouble() * 3,
        (r.nextDouble() - 0.5) * 12,
        colors[r.nextInt(colors.length)],
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_pieces, _c.value)),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final progress = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (progress <= 0 || progress >= 1) continue;
      final y = -20 + progress * p.speed * (size.height + 40);
      final x = p.x * size.width + sin(progress * pi * p.sway) * 24;
      final opacity = progress > 0.85 ? (1 - progress) / 0.15 : 1.0;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.spin);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
          const Radius.circular(2),
        ),
        Paint()..color = p.color.withOpacity(opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

/// Struttura comune delle schermate di gioco.
/// Senza l'effetto "elastico" di fine scorrimento, con [physics] per bloccare
/// lo scroll mentre si trascina sul campo e [celebrate] per i coriandoli.
class GameScaffold extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final ScrollPhysics? physics;
  final bool celebrate;

  /// Nei giochi a scorrimento il gesto "indietro" di Android (swipe dal bordo)
  /// parte per sbaglio: con [guardBack] serve farlo due volte per uscire.
  final bool guardBack;
  const GameScaffold({
    super.key,
    required this.title,
    required this.children,
    this.physics,
    this.celebrate = false,
    this.guardBack = false,
  });

  @override
  State<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold> {
  DateTime? _lastBack;

  void _onBack() {
    final now = DateTime.now();
    if (_lastBack != null && now.difference(_lastBack!) < const Duration(seconds: 2)) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.of(context).pop();
      return;
    }
    _lastBack = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.gameBackAgain),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.guardBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          // La freccia in alto esce subito: la protezione vale solo per il gesto.
          leading: widget.guardBack ? BackButton(onPressed: () => Navigator.of(context).pop()) : null,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                    child: ListView(
                      physics: widget.physics ?? const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: widget.children,
                    ),
                  ),
                ),
              ),
              if (widget.celebrate) const Positioned.fill(child: IgnorePointer(child: ConfettiOverlay())),
            ],
          ),
        ),
      ),
    );
  }
}
