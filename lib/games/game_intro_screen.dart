import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../widgets/christmas_decorations.dart';
import '../widgets/themed_banner.dart';
import 'battleship_screen.dart';
import 'block_screen.dart';
import 'busjam_screen.dart';
import 'flow_screen.dart';
import 'game2048_screen.dart';
import 'game_art.dart';
import 'game_common.dart';
import 'maze_screen.dart';
import 'memory_screen.dart';
import 'sudoku_screen.dart';
import 'tictactoe_screen.dart';
import 'wordle_screen.dart';

/// Pagina prima della partita: spiegazione breve del gioco e scelta della
/// difficoltà, poi "Gioca".
class GameIntroScreen extends StatefulWidget {
  final GameKind kind;
  const GameIntroScreen({super.key, required this.kind});

  @override
  State<GameIntroScreen> createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen> {
  Difficulty _difficulty = Difficulty.easy;

  bool get _hasDifficulty => widget.kind != GameKind.wordle;

  String _title(AppLocalizations l) => switch (widget.kind) {
        GameKind.busJam => l.gameBusJam,
        GameKind.sudoku => l.gameSudoku,
        GameKind.maze => l.gameMaze,
        GameKind.battleship => l.gameBattleship,
        GameKind.ticTacToe => l.gameTicTacToe,
        GameKind.blocks => l.gameBlocks,
        GameKind.g2048 => l.game2048,
        GameKind.memory => l.gameMemory,
        GameKind.wordle => l.gameWordle,
        GameKind.flow => l.gameFlow,
      };

  String _how(AppLocalizations l) => switch (widget.kind) {
        GameKind.busJam => l.gameBusJamHow,
        GameKind.sudoku => l.gameSudokuHow,
        GameKind.maze => l.gameMazeHow,
        GameKind.battleship => l.gameBattleshipHow,
        GameKind.ticTacToe => l.gameTicTacToeHow,
        GameKind.blocks => l.gameBlocksHow,
        GameKind.g2048 => l.game2048How,
        GameKind.memory => l.gameMemoryHow,
        GameKind.wordle => l.gameWordleHow,
        GameKind.flow => l.gameFlowHow,
      };

  Widget _game() => switch (widget.kind) {
        GameKind.busJam => BusJamScreen(difficulty: _difficulty),
        GameKind.sudoku => SudokuScreen(difficulty: _difficulty),
        GameKind.maze => MazeScreen(difficulty: _difficulty),
        GameKind.battleship => BattleshipScreen(difficulty: _difficulty),
        GameKind.ticTacToe => TicTacToeScreen(difficulty: _difficulty),
        GameKind.blocks => BlockScreen(difficulty: _difficulty),
        GameKind.g2048 => Game2048Screen(difficulty: _difficulty),
        GameKind.memory => MemoryScreen(difficulty: _difficulty),
        GameKind.wordle => const WordleScreen(),
        GameKind.flow => FlowScreen(difficulty: _difficulty),
      };

  Color get _levelColor => switch (_difficulty) {
        Difficulty.easy => Colors.green.shade600,
        Difficulty.medium => Colors.orange.shade700,
        Difficulty.hard => Colors.red.shade600,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final sub = widget.kind == GameKind.busJam
        ? l.gameLevel(BusJamScreen.unlocked(_difficulty))
        : (widget.kind == GameKind.wordle ? l.wordleToday : l.gameNew);
    return Scaffold(
      appBar: AppBar(title: Text(_title(l))),
      body: ChristmasBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Copertina del gioco (nei colori del tema)
                  ThemedBanner(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(height: 170, child: GameArt(widget.kind)),
                  ),
                  const SizedBox(height: 20),
                  Text(_title(l),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(_how(l),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.4, color: scheme.onSurfaceVariant)),
                  if (_hasDifficulty) ...[
                  const SizedBox(height: 28),
                  Text(l.gameDifficulty.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      difficultyLabel(l, _difficulty).toUpperCase(),
                      key: ValueKey(_difficulty),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: _levelColor),
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 14,
                      activeTrackColor: _levelColor,
                      thumbColor: _levelColor,
                      overlayColor: _levelColor.withOpacity(0.15),
                    ),
                    child: Slider(
                      value: _difficulty.index.toDouble(),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (v) => setState(() => _difficulty = Difficulty.values[v.round()]),
                    ),
                  ),
                  ],
                  const SizedBox(height: 20),
                  GameButton(
                    icon: Icons.play_arrow_rounded,
                    label: l.gamePlay,
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => _game()))
                        .then((_) => setState(() {})),
                  ),
                  const SizedBox(height: 6),
                  Text(sub,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
