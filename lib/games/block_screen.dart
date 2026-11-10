import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/block_logic.dart';

const _blockColors = [
  Color(0xFFFFC107), Color(0xFF7E57C2), Color(0xFF66BB6A), Color(0xFFEF5350),
  Color(0xFF42A5F5), Color(0xFFFF7043), Color(0xFF26C6DA),
];

/// Blocchi 1010: trascina i pezzi sulla griglia 10×10 e completa righe e colonne.
class BlockScreen extends StatefulWidget {
  final Difficulty difficulty;
  const BlockScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  final _rand = Random();
  List<int> _grid = List.filled(BlockLogic.size * BlockLogic.size, 0);
  List<BlockPiece?> _tray = [null, null, null];
  int _score = 0;
  bool _over = false;
  bool _newRecord = false;
  int? _dragIdx;
  Offset? _dragPos;
  (int, int)? _preview;
  bool _previewOk = false;
  bool _locked = false;
  int _gen = 0;

  String get _key => 'blocks_${widget.difficulty.name}';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _grid = List.filled(BlockLogic.size * BlockLogic.size, 0);
      _score = 0;
      _over = false;
      _newRecord = false;
      _dragIdx = null;
      _gen++;
      _refill();
    });
  }

  void _refill() {
    _tray = List.generate(3, (_) => BlockLogic.randomPiece(_rand, widget.difficulty.index));
  }

  // ----------------------------------------------------------------- geometria
  static const _gap = 14.0;

  double _cell(double side) => side / BlockLogic.size;
  double _trayTop(double side) => side + _gap;
  double _trayH(double side) => _cell(side) * 3.6;

  int? _slotAt(Offset p, double side) {
    if (p.dy < _trayTop(side) || p.dy > _trayTop(side) + _trayH(side)) return null;
    final k = (p.dx / (side / 3)).floor();
    return (k >= 0 && k < 3 && _tray[k] != null) ? k : null;
  }

  void _updatePreview(double side) {
    final i = _dragIdx, pos = _dragPos;
    if (i == null || pos == null) return;
    final piece = _tray[i]!;
    final cell = _cell(side);
    final left = pos.dx - piece.width * cell / 2;
    final top = pos.dy - cell * 2.4 - piece.height * cell / 2;
    final col = (left / cell).round(), row = (top / cell).round();
    _preview = (row, col);
    _previewOk = BlockLogic.canPlace(_grid, piece, row, col);
  }

  void _down(PointerDownEvent e, double side) {
    if (_over) return;
    final k = _slotAt(e.localPosition, side);
    if (k == null) return;
    setState(() {
      _locked = true;
      _dragIdx = k;
      _dragPos = e.localPosition;
      _updatePreview(side);
    });
  }

  void _move(PointerMoveEvent e, double side) {
    if (_dragIdx == null) return;
    setState(() {
      _dragPos = e.localPosition;
      _updatePreview(side);
    });
  }

  Future<void> _up(double side) async {
    final i = _dragIdx;
    if (i == null) {
      setState(() => _locked = false);
      return;
    }
    final piece = _tray[i]!;
    final pv = _preview;
    var placed = false;
    setState(() {
      if (pv != null && _previewOk) {
        final lines = BlockLogic.place(_grid, piece, pv.$1, pv.$2);
        _score += BlockLogic.points(piece, lines);
        _tray[i] = null;
        placed = true;
        if (_tray.every((p) => p == null)) _refill();
        _over = !_tray.any((p) => p != null && BlockLogic.canPlaceAnywhere(_grid, p));
      }
      _dragIdx = null;
      _dragPos = null;
      _preview = null;
      _locked = false;
    });
    if (placed) {
      final record = await GameStats.instance.submitHigh(_key, _score);
      if (mounted && _over) setState(() => _newRecord = record);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.high(_key);
    return GameScaffold(
      title: l.gameBlocks,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
      celebrate: _over && _newRecord,
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
                  key: ValueKey('over-$_gen-$_score'),
                  text: _newRecord ? '${l.gameOver} 🏆' : l.gameOver,
                  kind: _newRecord ? ResultKind.win : ResultKind.neutral,
                )
              : Text(l.gameBlocksHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        LayoutBuilder(builder: (context, box) {
          final side = min(box.maxWidth, 420.0);
          final height = side + _gap + _trayH(side);
          return Center(
            child: Listener(
              onPointerDown: (e) => _down(e, side),
              onPointerMove: (e) => _move(e, side),
              onPointerUp: (_) => _up(side),
              onPointerCancel: (_) => _up(side),
              child: SizedBox(
                width: side,
                height: height,
                child: CustomPaint(
                  painter: _BlockPainter(
                    grid: _grid,
                    tray: _tray,
                    side: side,
                    trayTop: _trayTop(side),
                    trayH: _trayH(side),
                    dragIdx: _dragIdx,
                    dragPos: _dragPos,
                    preview: _preview,
                    previewOk: _previewOk,
                    bg: scheme.surfaceContainerHighest,
                    empty: scheme.onSurface.withOpacity(0.06),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

class _BlockPainter extends CustomPainter {
  final List<int> grid;
  final List<BlockPiece?> tray;
  final double side, trayTop, trayH;
  final int? dragIdx;
  final Offset? dragPos;
  final (int, int)? preview;
  final bool previewOk;
  final Color bg, empty;
  _BlockPainter({
    required this.grid,
    required this.tray,
    required this.side,
    required this.trayTop,
    required this.trayH,
    required this.dragIdx,
    required this.dragPos,
    required this.preview,
    required this.previewOk,
    required this.bg,
    required this.empty,
  });

  void _block(Canvas c, double x, double y, double s, Color color, {double alpha = 1}) {
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, y + 1, s - 2, s - 2), Radius.circular(s * 0.18));
    c.drawRRect(r, Paint()..color = color.withOpacity(alpha));
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x + s * 0.16, y + s * 0.14, s - s * 0.32, s * 0.16), Radius.circular(s * 0.08)),
      Paint()..color = Colors.white.withOpacity(0.35 * alpha),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    const n = BlockLogic.size;
    final cell = side / n;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, side, side), const Radius.circular(14)),
        Paint()..color = bg);
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final v = grid[r * n + c];
        final x = c * cell, y = r * cell;
        if (v == 0) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(x + 1.5, y + 1.5, cell - 3, cell - 3), Radius.circular(cell * 0.14)),
              Paint()..color = empty);
        } else {
          _block(canvas, x, y, cell, _blockColors[(v - 1) % _blockColors.length]);
        }
      }
    }
    // anteprima di dove cadrà il pezzo
    final i = dragIdx;
    if (i != null && preview != null) {
      final piece = tray[i]!;
      for (final (dr, dc) in piece.cells) {
        final r = preview!.$1 + dr, c = preview!.$2 + dc;
        if (r < 0 || c < 0 || r >= n || c >= n) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cell + 1, r * cell + 1, cell - 2, cell - 2), Radius.circular(cell * 0.18)),
          Paint()..color = (previewOk ? Colors.green : Colors.red).withOpacity(0.38),
        );
      }
    }
    // vassoio con i tre pezzi
    final slotW = side / 3;
    final mini = cell * 0.6;
    for (var k = 0; k < 3; k++) {
      final p = tray[k];
      if (p == null || k == dragIdx) continue;
      final w = p.width * mini, h = p.height * mini;
      final ox = k * slotW + (slotW - w) / 2, oy = trayTop + (trayH - h) / 2;
      final playable = BlockLogic.canPlaceAnywhere(grid, p);
      for (final (dr, dc) in p.cells) {
        _block(canvas, ox + dc * mini, oy + dr * mini, mini, _blockColors[p.color], alpha: playable ? 1 : 0.35);
      }
    }
    // pezzo che segue il dito
    final pos = dragPos;
    if (i != null && pos != null) {
      final p = tray[i]!;
      final left = pos.dx - p.width * cell / 2;
      final top = pos.dy - cell * 2.4 - p.height * cell / 2;
      for (final (dr, dc) in p.cells) {
        _block(canvas, left + dc * cell, top + dr * cell, cell, _blockColors[p.color], alpha: 0.92);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BlockPainter old) => true;
}
